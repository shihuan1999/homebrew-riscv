#!/usr/bin/env python3
# 轮子重标记器 —— 把宿主标签的 wheel 改成 riscv64 musl 标签（交叉构建产物的标准后处理）。
# 做四件事：
#   1. 包内扩展模块文件名 x86_64-linux-gnu 后缀 → riscv64-linux-gnu（musl 同用 linux-gnu triple）
#   2. WHEEL 元数据 Tag: 改为目标平台标签（如 musllinux_1_2_riscv64）
#   3. RECORD 按新文件名重建（pip 安装时校验哈希，必须重算）
#   4. （可选 --strip <strip>）对包内 ELF 去 symbol
# 用法：
#   retag_wheel.py in.whl musllinux_1_2_riscv64 [--strip /path/to/riscv64-strip]
# 输出：同目录下 <name>-<ver>-<pytag>-<plttag>.whl；退出码 0/1。
# 注意：只适用于"编译目标确实是 riscv64 musl"的交叉构建产物；禁止用它把
# glibc 二进制伪装成 musllinux（生态陷阱，见 wheels/README.md）。

import argparse
import base64
import csv
import hashlib
import io
import re
import subprocess
import sys
import zipfile
from pathlib import Path

HOST_SUFFIX_RE = re.compile(r"\.cpython-(\d+)-x86_64-linux-gnu\.so$")
TARGET_SUFFIX = ".cpython-{ver}-riscv64-linux-gnu.so"


def b32sha(data: bytes) -> str:
    return base64.urlsafe_b64encode(hashlib.sha256(data).digest()).rstrip(b"=").decode()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("wheel")
    ap.add_argument("platform_tag")
    ap.add_argument("--strip", default=None)
    args = ap.parse_args()

    src = Path(args.wheel)
    if not src.exists():
        print(f"no such wheel: {src}", file=sys.stderr)
        return 1
    m = re.match(r"^(.+)-([^-]+)-([^-]+)-([^-]+)\.whl$", src.name)
    if not m:
        print(f"bad wheel filename: {src.name}", file=sys.stderr)
        return 1
    dist, ver, pytag, _ = m.groups()
    out = src.with_name(f"{dist}-{ver}-{pytag}-{args.platform_tag}.whl")

    zin = zipfile.ZipFile(src)
    names = zin.namelist()
    renamed = {}
    for n in names:
        mm = HOST_SUFFIX_RE.search(n)
        if mm:
            pyver = mm.group(1)
            renamed[n] = n[:mm.start()] + TARGET_SUFFIX.format(ver=pyver)

    data = {}
    for n in names:
        raw = zin.read(n)
        if args.strip and (n.endswith(".so") or renamed.get(n, n).endswith(".so")):
            try:
                r = subprocess.run([args.strip, "--strip-unneeded", "/dev/stdout"],
                                   input=raw, capture_output=True)
                # strip 到 stdout 对部分实现不可用，落临时文件更稳
                if r.returncode != 0 or not r.stdout.startswith(b"\x7fELF"):
                    import tempfile, os
                    with tempfile.NamedTemporaryFile(suffix=".so", delete=False) as tf:
                        tf.write(raw)
                        tmp = tf.name
                    try:
                        subprocess.run([args.strip, "--strip-unneeded", tmp], check=True)
                        raw = Path(tmp).read_bytes()
                    finally:
                        os.unlink(tmp)
                else:
                    raw = r.stdout
            except Exception as e:
                print(f"WARN: strip failed for {n}: {e}", file=sys.stderr)
        data[renamed.get(n, n)] = raw

    # WHEEL Tag 重写（保留其余行）
    wheelmeta = None
    for n in list(data):
        if n.endswith(".dist-info/WHEEL"):
            lines = data[n].decode().splitlines()
            lines = [l for l in lines if not l.startswith("Tag:")]
            lines.append(f"Tag: {pytag}-{args.platform_tag}")
            data[n] = ("\n".join(lines) + "\n").encode()
            wheelmeta = n
    if not wheelmeta:
        print("no .dist-info/WHEEL in archive", file=sys.stderr)
        return 1

    # RECORD 重建
    rec = None
    for n in list(data):
        if n.endswith(".dist-info/RECORD"):
            rec = n
    if rec:
        del data[rec]
        buf = io.StringIO()
        w = csv.writer(buf, lineterminator="\n")
        for n in sorted(data):
            w.writerow([n, f"sha256={b32sha(data[n])}", str(len(data[n]))])
        w.writerow([rec, "", ""])
        data[rec] = buf.getvalue().encode()

    with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as zout:
        for n in sorted(data):
            zout.writestr(n, data[n])
    print(f"OK: {out.name} ({sum(len(v) for v in data.values())} bytes raw, "
          f"{len(renamed)} extension(s) renamed)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
