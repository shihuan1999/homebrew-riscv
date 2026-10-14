#!/usr/bin/env python3
# riscv64_ohos formula 校验器 —— CI 门禁的 formula 侧检查。
# 检查项：
#   语法   ruby -c（runner 上有 ruby 时）
#   结构   类名与文件名一致、desc/homepage/url/sha256/version、bottle 块、
#          resource 块成对 url+sha256、install/test 块存在
#   约定   bottle 必须带 riscv64_ohos 标签；test 不得是空壳 system "true"（警告）
#   依赖   depends_on 的每个名字必须能在 tap（Formula/<字母>/<名>.rb）找到，
#          内置虚拟包（portable-ruby 等）白名单放行
#   安全   url/root_url/resource url 禁止指向私网地址（10.x/127.x/192.168.x/172.16-31.x）
#          —— 内网源对第三方不可达，是历史踩过的坑，必须挡住
#   bottle 可选 --fetch-bottle：按 brew fork 的命名规则推导 bottle URL
#          （<root_url>/<name>-<version>.riscv64_ohos.bottle.tar.gz），下载后
#          校验 sha256 并调用 validate_bottle.py 做结构/架构校验
# 纯标准库 + 可选 ruby。用法：
#   validate_formula.py <formula.rb> [--tap-root DIR] [--fetch-bottle] [--workdir DIR]

import argparse
import os
import re
import shutil
import subprocess
import sys
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
PLATFORM_TAG = "riscv64_ohos"
BOTTLE_FILENAME_RE = re.compile(r"[^A-Za-z0-9._+-]")

# 虚拟依赖：tap 内没有同名 formula 但允许 depends_on
VIRTUAL_DEPS = {"portable-ruby", "portable-git"}

PRIVATE_IP_RE = re.compile(
    r"https?://("
    r"10\.\d+\.\d+\.\d+|127\.\d+\.\d+\.\d+|192\.168\.\d+\.\d+"
    r"|172\.(1[6-9]|2\d|3[01])\.\d+\.\d+|localhost|\[::1\]"
    r")(:\d+)?"
)


class Report:
    def __init__(self):
        self.errors = []
        self.warnings = []
        self.info = {}

    def error(self, m):
        self.errors.append(m)

    def warn(self, m):
        self.warnings.append(m)

    @property
    def ok(self):
        return not self.errors


def camel(name):
    # Homebrew 规则：python@3.11 → PythonAT311（@ 后的段大写 AT 拼接、去掉点）
    parts = re.split(r"[-_]", name)
    out = "".join(p.capitalize() for p in parts if p)
    return re.sub(r"@(\d+(?:\.\d+)*)", lambda m: "AT" + m.group(1).replace(".", ""), out)


def parse_formula(text):
    """宽松提取 formula 关键字段（regex，不执行 ruby）。"""
    out = {}
    m = re.search(r"^\s*class\s+(\w+)\s*<\s*Formula", text, re.M)
    out["class"] = m.group(1) if m else None
    for field in ("desc", "homepage", "url", "sha256", "version", "license"):
        m = re.search(r'^\s*%s\s+"([^"]+)"' % field, text, re.M)
        out[field] = m.group(1) if m else None
    # depends_on（排除 depends_on :xxx 符号形式）
    out["depends_on"] = re.findall(r'^\s*depends_on\s+"([^"]+)"', text, re.M)
    # bottle 块
    m = re.search(r"bottle\s+do(.*?)end", text, re.S)
    out["bottle_raw"] = m.group(1) if m else None
    out["root_url"] = None
    out["bottle_sha256"] = None
    if m:
        b = m.group(1)
        ru = re.search(r'root_url\s+"([^"]+)"', b)
        out["root_url"] = ru.group(1) if ru else None
        shas = re.findall(r"sha256\s+cellar:\s*:\w+\s*,\s*%s:\s*\"([0-9a-fA-F]{64})\"" % PLATFORM_TAG, b)
        out["bottle_sha256"] = shas[0] if shas else None
        out["bottle_multi_tag"] = len(re.findall(r"riscv64_\w+\s*:", b))
    # resource 块
    out["resources"] = re.findall(
        r'resource\s+"([^"]+)"\s+do\s*\n(.*?)\n\s*end', text, re.S)
    out["has_install"] = bool(re.search(r"def\s+install\b", text))
    # test 支持两种写法：def test ... end（新）与 test do ... end（旧 DSL）
    m = re.search(r"def\s+test\b(.*?)\n\s*end", text, re.S) or \
        re.search(r"^\s*test\s+do(.*?)\n\s*end", text, re.S | re.M)
    out["test_body"] = m.group(1).strip() if m else None
    return out


def validate(path, tap_root=None, report=None, allow_private_urls=False):
    rep = report or Report()
    name = os.path.splitext(os.path.basename(path))[0]
    rep.info["name"] = name
    text = open(path, encoding="utf-8", errors="replace").read()

    # ruby 语法（可选）
    if shutil.which("ruby"):
        r = subprocess.run(["ruby", "-c", path], capture_output=True, text=True)
        if r.returncode != 0:
            rep.error(f"ruby syntax: {r.stderr.strip()[:300]}")
    else:
        rep.warn("ruby not available, skipped ruby -c syntax check")

    f = parse_formula(text)
    if not f["class"]:
        rep.error("no `class X < Formula` declaration")
        return rep
    if f["class"].lower() != camel(name).lower():
        rep.error(f"class name {f['class']} != expected {camel(name)} for file {name}.rb")
    for field in ("desc", "homepage", "url"):
        if not f[field]:
            rep.error(f"missing required field: {field}")
    if not f["sha256"] and not f["bottle_raw"]:
        rep.error("missing source sha256 (or bottle block)")
    if f["sha256"] and not re.fullmatch(r"[0-9a-fA-F]{64}", f["sha256"]):
        rep.error(f"bad source sha256: {f['sha256']}")
    if not f["has_install"]:
        rep.error("missing `def install`")
    if not f["test_body"]:
        rep.error("missing `def test`")
    elif 'system "true"' in f["test_body"]:
        rep.warn('test block is a stub (system "true") — please run a real smoke command')

    # bottle 块
    if f["bottle_raw"]:
        if not f["root_url"]:
            rep.error("bottle block missing root_url")
        if not f["bottle_sha256"]:
            rep.error(f"bottle block missing sha256 for {PLATFORM_TAG}")
        rep.info["bottle_sha256"] = f["bottle_sha256"]
    else:
        rep.warn("no bottle block — source-only formula (needs build-from-source CI)")

    # 依赖闭包（支持 hbrew/riscv/<name> 限定名）
    if tap_root:
        for dep in f["depends_on"]:
            dep_base = dep.split("/")[-1]
            if dep_base in VIRTUAL_DEPS:
                continue
            letter = dep_base[0].lower()
            if not os.path.exists(os.path.join(tap_root, "Formula", letter, f"{dep_base}.rb")) \
               and not os.path.exists(os.path.join(tap_root, "Formula", f"{dep_base}.rb")):
                rep.error(f"depends_on \"{dep}\" not found in tap (missing Formula/{letter}/{dep_base}.rb)")

    # 私网 URL 检查（所有出现过的 http URL）
    urls = [u for u in (f["url"], f["root_url"]) if u]
    for rname, rbody in f["resources"]:
        mu = re.search(r'url\s+"([^"]+)"', rbody)
        if mu:
            urls.append(mu.group(1))
    for u in urls:
        if PRIVATE_IP_RE.match(u):
            if allow_private_urls:
                rep.warn(f"private-network URL (legacy, allowed here): {u}")
            else:
                rep.error(f"private-network URL is not reachable for third parties: {u}")

    rep.info["deps"] = f["depends_on"]
    rep.info["root_url"] = f["root_url"]
    rep.info["version"] = f["version"]
    return rep, f


def bottle_filename(name, version):
    return f"{name}-{version}.{PLATFORM_TAG}.bottle.tar.gz"


def fetch_bottle(rep, f, name, version, workdir):
    root_url = f["root_url"]
    if not root_url or not f["bottle_sha256"]:
        rep.error("cannot fetch bottle: no root_url/bottle sha256 in formula")
        return
    url = f"{root_url.rstrip('/')}/{bottle_filename(name, version)}"
    rep.info["bottle_url"] = url
    dest = os.path.join(workdir, bottle_filename(name, version))
    try:
        print(f"downloading {url} ...", file=sys.stderr)
        req = urllib.request.Request(url, headers={"User-Agent": "hbrew-ci/1.0"})
        with urllib.request.urlopen(req, timeout=300) as r, open(dest, "wb") as out:
            shutil.copyfileobj(r, out)
    except Exception as e:
        rep.error(f"bottle download failed from {url}: {e}")
        return
    r = subprocess.run([sys.executable, os.path.join(HERE, "validate_bottle.py"), dest,
                        "--expect-sha256", f["bottle_sha256"],
                        "--name", name, "--version", version, "--json"],
                       capture_output=True, text=True)
    print(r.stdout)
    try:
        sub = __import__("json").loads(r.stdout)
        rep.errors.extend(sub.get("errors", []))
        rep.warnings.extend(sub.get("warnings", []))
        rep.info["bottle"] = sub.get("info", {})
    except Exception:
        rep.error("validate_bottle.py did not produce JSON output")
    if r.returncode != 0 and not [e for e in rep.errors if "bottle" in e or "sha" in e or "ELF" in e or "keg" in e]:
        rep.error(f"bottle validation exited {r.returncode}")


def derive_version(rep, f, text):
    if f["version"]:
        return f["version"]
    m = re.search(r'url\s+"([^"]+)"', text)
    if m:
        u = m.group(1)
        # 取路径里最后一段中第一个数字开头的版本号（宽松）
        vm = re.search(r"v?(\d[\w.+-]*?)(?:\.tar\.(gz|xz|bz2)|\.tgz|/)?$",
                       os.path.basename(u))
        if vm:
            rep.warn(f"version not explicit, derived from url: {vm.group(1)}")
            return vm.group(1)
    rep.error("cannot derive version (no version field, no versioned url)")
    return None


def main():
    ap = argparse.ArgumentParser(description="riscv64_ohos formula validator")
    ap.add_argument("formula")
    ap.add_argument("--tap-root", default=None)
    ap.add_argument("--fetch-bottle", action="store_true")
    ap.add_argument("--allow-private-urls", action="store_true")
    ap.add_argument("--workdir", default=None)
    args = ap.parse_args()

    workdir = args.workdir or os.getcwd()
    os.makedirs(workdir, exist_ok=True)
    result = validate(args.formula, args.tap_root, None, args.allow_private_urls)
    rep, f = result
    version = derive_version(rep, f, open(args.formula, encoding="utf-8", errors="replace").read())
    rep.info["version"] = rep.info["version"] or version
    if args.fetch_bottle and f["bottle_raw"]:
        fetch_bottle(rep, f, rep.info["name"], rep.info["version"], workdir)

    for w in rep.warnings:
        print(f"WARN: {w}", file=sys.stderr)
    for e in rep.errors:
        print(f"ERROR: {e}", file=sys.stderr)
    print(f"{'PASS' if rep.ok else 'FAIL'} {args.formula} name={rep.info['name']} "
          f"version={rep.info.get('version')} deps={','.join(rep.info.get('deps', [])) or '-'}")
    sys.exit(0 if rep.ok else 1)


if __name__ == "__main__":
    main()
