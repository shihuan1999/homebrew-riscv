#!/usr/bin/env python3
# riscv64_ohos bottle 校验器 —— CI 门禁的核心。
# 校验一个 .riscv64_ohos.bottle.tar.gz：
#   1. 整体 sha256 与期望值一致（如提供）
#   2. tar 结构：顶层必须且只能是 <name>/<version>/ keg 布局
#   3. 安全：无绝对路径/..、无 symlink 越出 keg、无设备文件、无 setuid/setgid
#   4. 架构：bin|sbin|libexec|lib 下所有 ELF 必须是 riscv64；动态 ELF 的
#      NEEDED 不得出现 glibc 特征（libc.so.6 / ld-linux-*），解释器应为
#      ld-musl-riscv64.so.1（或完全静态）
#   5. 体积上限（默认 400MB）、keg 非空、bin|lib 至少其一有内容（警告级）
# 纯标准库实现，无第三方依赖，可在 GitHub-hosted runner / snode7 / 设备本机运行。
# 用法：
#   validate_bottle.py <bottle.tar.gz> [--expect-sha256 HEX] [--name N] [--version V] [--json]
# 退出码：0 通过；1 存在 error；2 用法错误。

import argparse
import hashlib
import io
import json
import os
import posixpath
import stat
import sys
import tarfile

EM_RISCV = 243
EM_NAMES = {243: "riscv", 183: "aarch64", 62: "x86_64", 40: "arm", 3: "x86"}
PT_INTERP = 3
PT_DYNAMIC = 2
DT_NULL = 0
DT_NEEDED = 1
DT_STRTAB = 5
DEFAULT_MAX_BYTES = 400 * 1024 * 1024
EXEC_DIRS = ("bin", "sbin", "libexec")
LIB_DIRS = ("lib", "lib64")


class Report:
    def __init__(self):
        self.errors = []
        self.warnings = []
        self.info = {}

    def error(self, msg):
        self.errors.append(msg)

    def warn(self, msg):
        self.warnings.append(msg)

    @property
    def ok(self):
        return not self.errors


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def parse_elf(data):
    """返回 dict：{class, machine, type, interp, needed[]}；非 ELF 返回 None。"""
    if len(data) < 64 or data[:4] != b"\x7fELF":
        return None
    ei_class = data[4]  # 1=32bit 2=64bit
    ei_data = data[5]   # 1=LE 2=BE
    if ei_data != 1:
        return {"class": ei_class, "machine": None, "type": None,
                "interp": None, "needed": [], "big_endian": True}
    import struct
    (e_type, e_machine) = struct.unpack_from("<HH", data, 16)
    out = {"class": ei_class, "machine": e_machine, "type": e_type,
           "interp": None, "needed": [], "big_endian": False}
    if ei_class != 2:
        return out
    (e_phoff,) = struct.unpack_from("<Q", data, 32)
    (e_phentsize,) = struct.unpack_from("<H", data, 54)
    (e_phnum,) = struct.unpack_from("<H", data, 56)
    interp_off = dyn_off = dyn_sz = None
    for i in range(e_phnum):
        base = e_phoff + i * e_phentsize
        if base + 56 > len(data):
            break
        (p_type, p_flags, p_offset, p_vaddr, p_paddr, p_filesz, p_memsz,
         p_align) = struct.unpack_from("<IIQQQQQQ", data, base)
        if p_type == PT_INTERP and interp_off is None:
            interp_off, _ = p_offset, p_filesz
        elif p_type == PT_DYNAMIC and dyn_off is None:
            dyn_off, dyn_sz = p_offset, p_filesz
    if interp_off is not None:
        end = data.find(b"\x00", interp_off)
        out["interp"] = data[interp_off:end].decode("ascii", "replace")
    if dyn_off is not None:
        strtab = None
        needed_offs = []
        end = min(dyn_off + dyn_sz, len(data))
        pos = dyn_off
        while pos + 16 <= end:
            (d_tag, d_val) = struct.unpack_from("<qQ", data, pos)
            if d_tag == DT_NULL:
                break
            if d_tag == DT_NEEDED:
                needed_offs.append(d_val)
            elif d_tag == DT_STRTAB:
                strtab = d_val
            pos += 16
        if strtab is not None and needed_offs:
            if strtab < len(data):
                out["needed"] = _read_strtab_entries(data, strtab, needed_offs)
    return out


def _read_strtab_entries(data, strtab, offsets):
    names = []
    for off in offsets:
        pos = strtab + off
        if pos >= len(data):
            continue
        end = data.find(b"\x00", pos)
        if end < 0:
            continue
        names.append(data[pos:end].decode("utf-8", "replace"))
    return names


GLIBC_MARKERS = ("libc.so.6", "ld-linux-", "ld64.so.", "libm.so.6", "libpthread.so.0")


def validate_bottle(path, expect_sha=None, name=None, version=None,
                    max_bytes=DEFAULT_MAX_BYTES, report=None):
    rep = report or Report()
    rep.info["file"] = os.path.basename(path)
    rep.info["size_bytes"] = os.path.getsize(path)
    if rep.info["size_bytes"] > max_bytes:
        rep.error(f"bottle too large: {rep.info['size_bytes']} > {max_bytes} bytes")

    actual_sha = sha256_file(path)
    rep.info["sha256"] = actual_sha
    if expect_sha and expect_sha.lower() != actual_sha:
        rep.error(f"sha256 mismatch: bottle={actual_sha} expected={expect_sha}")

    try:
        tf = tarfile.open(path, "r:gz")
    except Exception as e:
        rep.error(f"not a valid gzip tar: {e}")
        return rep

    members = tf.getmembers()
    top_dirs = set()
    keg_prefixes = []
    n_elf = n_bad_elf = n_dynamic = 0
    elf_machines = set()
    contents_flagged_dirs = set()
    file_count = 0
    total_unpacked = 0

    for m in members:
        rp = m.name.lstrip("./")
        if not rp:
            continue
        parts = rp.split("/")
        # 路径安全
        if m.name.startswith("/") or ".." in parts:
            rep.error(f"unsafe path in tar: {m.name}")
            continue
        if len(parts) == 1 and (m.isdir() or m.isfile() or m.issym()):
            top_dirs.add(parts[0])
        if m.isdir():
            continue
        file_count += 1
        total_unpacked += m.size
        # 顶层布局：<name>/<version>/...
        if len(parts) >= 3:
            keg_prefixes.append("/".join(parts[:2]))
        # 设备文件
        if m.ischr() or m.isblk() or m.isfifo():
            rep.error(f"special file not allowed in bottle: {m.name}")
            continue
        # setuid/setgid
        if m.isfile() and (m.mode & stat.S_ISUID or m.mode & stat.S_ISGID):
            rep.error(f"setuid/setgid file not allowed: {m.name} (mode {oct(m.mode)})")
        # symlink 越界
        if m.issym():
            target = posixpath.normpath(posixpath.join(posixpath.dirname(rp), m.linkname))
            if target.startswith("..") or target.startswith("/"):
                rep.error(f"symlink escapes keg: {m.name} -> {m.linkname}")
            continue
        if not m.isfile():
            continue
        first = parts[0] if parts else ""
        second = parts[1] if len(parts) > 1 else ""
        # keg 布局 <name>/<version>/<sub>/... —— bin/lib 判定跳过 keg 前缀两段
        inner = parts[2] if len(parts) > 2 else first
        in_exec = inner in EXEC_DIRS or (inner == "opt" and len(parts) > 3 and parts[3] in EXEC_DIRS)
        in_lib = inner in LIB_DIRS or (inner == "opt" and len(parts) > 3 and parts[3] in LIB_DIRS)
        if in_exec:
            contents_flagged_dirs.add("exec")
        if in_lib:
            contents_flagged_dirs.add("lib")
        if not (in_exec or in_lib):
            continue
        # 提取并检查 ELF（限制单文件读取 64MB 防炸内存）
        f = tf.extractfile(m)
        if f is None:
            continue
        head = f.read(min(64 * 1024 * 1024, m.size + 1))
        if len(head) < 20 or head[:4] != b"\x7fELF":
            # 非 ELF（脚本/数据）放行
            continue
        n_elf += 1
        info = parse_elf(head)
        if info is None:
            continue
        elf_machines.add(info["machine"])
        if info["machine"] != EM_RISCV:
            n_bad_elf += 1
            rep.error(f"non-riscv64 ELF: {m.name} (machine={EM_NAMES.get(info['machine'], info['machine'])})")
            continue
        if info["class"] != 2:
            n_bad_elf += 1
            rep.error(f"non-64bit ELF: {m.name}")
            continue
        if info["interp"]:
            n_dynamic += 1
            if "musl" not in info["interp"]:
                rep.error(f"ELF interpreter is not musl: {m.name} (interp={info['interp']})")
        for nd in info["needed"]:
            if any(nd == mk or nd.startswith(mk) for mk in GLIBC_MARKERS):
                rep.error(f"glibc-linked ELF: {m.name} (NEEDED {nd})")

    rep.info["files"] = file_count
    rep.info["elf_count"] = n_elf
    rep.info["elf_dynamic_count"] = n_dynamic
    rep.info["elf_machines"] = sorted(EM_NAMES.get(m, str(m)) for m in elf_machines)
    rep.info["unpacked_bytes"] = total_unpacked

    if file_count == 0:
        rep.error("bottle contains no files")
    # keg 布局
    unique_kegs = sorted(set(keg_prefixes))
    rep.info["kegs"] = unique_kegs
    if not unique_kegs:
        rep.error("no <name>/<version>/ keg layout found (top-level files must live under <name>/<version>/)")
    else:
        if len(unique_kegs) > 1:
            rep.error(f"multiple kegs in one bottle: {unique_kegs}")
        kname, _, kver = unique_kegs[0].partition("/")
        if name and kname != name:
            rep.error(f"keg name '{kname}' != formula name '{name}'")
        if version and kver != str(version):
            rep.error(f"keg version '{kver}' != formula version '{version}'")
        # 顶层只允许 keg 名（外加 meta 文件如 .brew/ 等，警告）
        extra = top_dirs - {kname}
        if extra:
            rep.warn(f"unexpected top-level entries (will be ignored by brew): {sorted(extra)}")
    if "exec" not in contents_flagged_dirs and "lib" not in contents_flagged_dirs:
        rep.warn("keg has no bin/sbin/libexec/lib content — data-only bottle?")
    return rep


def main():
    ap = argparse.ArgumentParser(description="riscv64_ohos bottle validator")
    ap.add_argument("bottle")
    ap.add_argument("--expect-sha256")
    ap.add_argument("--name")
    ap.add_argument("--version")
    ap.add_argument("--max-mb", type=int, default=400)
    ap.add_argument("--json", action="store_true")
    args = ap.parse_args()

    rep = validate_bottle(args.bottle, args.expect_sha256, args.name,
                          args.version, args.max_mb * 1024 * 1024)
    if args.json:
        print(json.dumps({"ok": rep.ok, "errors": rep.errors,
                          "warnings": rep.warnings, "info": rep.info}, indent=2))
    else:
        for w in rep.warnings:
            print(f"WARN: {w}", file=sys.stderr)
        for e in rep.errors:
            print(f"ERROR: {e}", file=sys.stderr)
        print(f"{'PASS' if rep.ok else 'FAIL'} {args.bottle} "
              f"(files={rep.info.get('files')}, elf={rep.info.get('elf_count')}, "
              f"sha256={rep.info.get('sha256', '')[:16]}…)")
    sys.exit(0 if rep.ok else 1)


if __name__ == "__main__":
    main()
