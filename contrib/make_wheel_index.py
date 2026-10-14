#!/usr/bin/env python3
# riscv64 musl wheel 索引生成器 —— 把 wheels/manifest.json 渲染成 PEP 503 simple 索引。
# 轮子本体放 GitHub release(tag=wheels) 的 asset，本脚本只生成指向 asset 的 HTML。
# 产物：wheels/simple/index.html 与 wheels/simple/<norm-name>/index.html
# 约定：manifest 条目必须带 name/version/url/sha256/tag/origin；
#       url 一律指向 https://github.com/shihuan1999/homebrew-riscv/releases/download/wheels/
# 用法：python3 contrib/make_wheel_index.py [--manifest wheels/manifest.json] [--out wheels/simple]
# 退出码：0 成功；1 manifest 非法。

import argparse
import datetime
import html
import json
import re
import sys
from pathlib import Path

RELEASE_BASE = "https://github.com/shihuan1999/homebrew-riscv/releases/download/wheels/"


def norm_name(name: str) -> str:
    """PEP 503 名称归一化：小写 + 连续 [-_.] 折叠为 -"""
    return re.sub(r"[-_.]+", "-", name).lower()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--manifest", default="wheels/manifest.json")
    ap.add_argument("--out", default="wheels/simple")
    args = ap.parse_args()

    mpath = Path(args.manifest)
    if not mpath.exists():
        print(f"manifest not found: {mpath}", file=sys.stderr)
        return 1
    manifest = json.loads(mpath.read_text(encoding="utf-8"))
    wheels = manifest.get("wheels", [])

    seen = {}
    errors = []
    for w in wheels:
        for k in ("name", "version", "url", "sha256", "tag"):
            if not w.get(k):
                errors.append(f"entry missing {k}: {w.get('name')}")
        url = w.get("url", "")
        if url and not url.startswith(RELEASE_BASE):
            errors.append(f"url outside wheels release: {url}")
        if url in seen:
            errors.append(f"duplicate url: {url}")
        seen[url] = True
    if errors:
        for e in errors:
            print("ERROR:", e, file=sys.stderr)
        return 1

    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    packages = {}
    for w in wheels:
        packages.setdefault(norm_name(w["name"]), []).append(w)

    for pkg, entries in packages.items():
        pdir = out / pkg
        pdir.mkdir(parents=True, exist_ok=True)
        lines = [f"<html><head><title>Links for {html.escape(pkg)}</title></head><body>",
                 f"<h1>Links for {html.escape(pkg)}</h1>"]
        for w in sorted(entries, key=lambda e: e["version"]):
            fname = w["url"].rsplit("/", 1)[-1]
            extra = f" ({html.escape(w['tag'])}, built from {html.escape(w.get('origin', 'source'))})"
            lines.append(f'<a href="{html.escape(w["url"])}#sha256={w["sha256"]}">'
                         f"{html.escape(fname)}</a>{extra}<br/>")
        lines.append(f"</body><!-- updated {manifest.get('updated', '')} --></html>")
        (pdir / "index.html").write_text("\n".join(lines), encoding="utf-8")

    root = [f"<html><head><title>harmonybrew riscv64 musl wheels</title></head><body>",
            "<h1>harmonybrew riscv64 musl wheel index</h1>"]
    for pkg in sorted(packages):
        root.append(f'<a href="{pkg}/">{html.escape(pkg)}</a><br/>')
    root.append(f"</body><!-- {len(packages)} packages, updated {manifest.get('updated', '')} --></html>")
    (out / "index.html").write_text("\n".join(root), encoding="utf-8")
    print(f"OK: {len(packages)} packages, {len(wheels)} wheels -> {out}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
