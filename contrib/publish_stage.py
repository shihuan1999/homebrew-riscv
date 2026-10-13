#!/usr/bin/env python3
# publish 工作流第一步：为每个变更的 formula 准备并校验 bottle。
#   优先用 build-source 的 artifact（源码贡献）；
#   否则按 formula root_url 下载（二进制贡献，托管在贡献者自己的 release）；
#   统一校验 sha256 + 结构/架构后落到 staged/，输出 staged.json 供后续步骤使用。
import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
CENTRAL_ROOT = os.environ.get("HBREW_CENTRAL_ROOT",
                              "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles")
PLATFORM = "riscv64_ohos"


def parse_formula(path):
    t = open(path, encoding="utf-8", errors="replace").read()
    out = {}
    m = re.search(r"^\s*class\s+(\w+)\s*<\s*Formula", t, re.M)
    out["name"] = m.group(1).lower() if m else None
    m = re.search(r'^\s*version\s+"([^"]+)"', t, re.M)
    out["version"] = m.group(1) if m else None
    m = re.search(r'bottle\s+do.*?root_url\s+"([^"]+)"', t, re.S)
    out["root_url"] = m.group(1) if m else None
    m = re.search(r"sha256\s+cellar:\s*:\w+\s*,\s*%s:\s*\"([0-9a-fA-F]{64})\"" % PLATFORM, t)
    out["bottle_sha256"] = m.group(1) if m else None
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--changed", required=True)
    ap.add_argument("--bottle-dir", required=True)
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    os.makedirs("staged", exist_ok=True)
    results = []
    for line in open(args.changed):
        f = line.strip()
        if not f.endswith(".rb"):
            continue
        info = parse_formula(f)
        name, ver = info["name"], info["version"]
        if not name:
            print(f"SKIP (no class): {f}", file=sys.stderr)
            continue
        entry = {"formula": f, "name": name, "version": ver}

        # 版本兜底：从 url 推导
        if not ver:
            m = re.search(r'url\s+"([^"]+)"', open(f, encoding="utf-8", errors="replace").read())
            if m:
                vm = re.search(r"v?(\d[\w.+-]*?)(?:\.tar\.(gz|xz|bz2)|\.tgz|/)?$",
                               os.path.basename(m.group(1)))
                ver = vm.group(1) if vm else None
            entry["version"] = ver
        if not ver:
            print(f"ERROR cannot resolve version for {name}", file=sys.stderr)
            sys.exit(1)

        asset = f"{name}-{ver}.{PLATFORM}.bottle.tar.gz"
        entry["asset"] = asset
        local = os.path.join("staged", asset)

        # 1) artifact 优先
        cand = os.path.join(args.bottle_dir, asset)
        if os.path.exists(cand):
            shutil.copy2(cand, local)
            entry["source"] = "artifact"
        # 2) root_url 下载（二进制贡献）
        elif info["root_url"]:
            url = f"{info['root_url'].rstrip('/')}/{asset}"
            entry["bottle_url"] = url
            try:
                req = urllib.request.Request(url, headers={"User-Agent": "hbrew-ci/1.0"})
                with urllib.request.urlopen(req, timeout=600) as r, open(local, "wb") as o:
                    shutil.copyfileobj(r, o)
                entry["source"] = "root_url"
            except Exception as e:
                print(f"ERROR download {url}: {e}", file=sys.stderr)
                sys.exit(1)
        else:
            print(f"ERROR no artifact and no root_url for {name} — cannot publish bottle", file=sys.stderr)
            sys.exit(1)

        # 3) 校验：自家 build-source artifact 视为可信产物（重建场景 sha 会变，
        #    发布时以 artifact 实际 sha 更新 formula）；第三方 root_url 资产
        #    必须与 formula 声明的 sha256 完全一致，防篡改
        expect = info["bottle_sha256"] if entry["source"] == "root_url" else None
        r = subprocess.run([sys.executable, os.path.join(HERE, "validate_bottle.py"), local,
                            "--name", name, "--version", ver,
                            *(["--expect-sha256", expect] if expect else []),
                            "--json"], capture_output=True, text=True)
        try:
            sub = json.loads(r.stdout)
        except Exception:
            print(r.stdout, r.stderr)
            sys.exit(1)
        if sub["errors"]:
            print(f"BOTTLE INVALID {name}: {sub['errors']}", file=sys.stderr)
            sys.exit(1)
        import hashlib
        h = hashlib.sha256(open(local, "rb").read()).hexdigest()
        entry["staged"] = local
        entry["sha256"] = h
        entry["old_sha256"] = info["bottle_sha256"]
        results.append(entry)
        print(f"staged {name}-{ver}: sha256={h[:16]}… ({entry['source']}, {sub['info'].get('elf_count', 0)} elf)")

    json.dump(results, open(args.out, "w"), indent=2)
    print(json.dumps(results, indent=2))


if __name__ == "__main__":
    main()
