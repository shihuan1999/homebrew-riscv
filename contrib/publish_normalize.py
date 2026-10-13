#!/usr/bin/env python3
# publish 工作流第二步：把变更 formula 的 bottle 块规范化为中央托管地址。
#   - root_url 统一指向中央 release（HBREW_CENTRAL_ROOT）
#   - 源码贡献（原本无 bottle 块）自动补写 bottle 块
#   - sha256 与实际上传资产对齐
import argparse
import json
import os
import re
import sys

CENTRAL_ROOT = os.environ.get("HBREW_CENTRAL_ROOT",
                              "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles")
PLATFORM = "riscv64_ohos"

BOTTLE_BLOCK = '''
  bottle do
    root_url "{root}"
    sha256 cellar: :any_skip_relocation, {tag}: "{sha}"
  end
'''


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--changed", required=True)
    ap.add_argument("--staged", required=True)
    args = ap.parse_args()

    staged = {e["name"]: e for e in json.load(open(args.staged))}
    changed = [l.strip() for l in open(args.changed) if l.strip().endswith(".rb")]

    for f in changed:
        t = open(f, encoding="utf-8", errors="replace").read()
        m = re.search(r"^\s*class\s+(\w+)\s*<\s*Formula", t, re.M)
        if not m:
            continue
        name = m.group(1).lower()
        e = staged.get(name)
        if not e:
            continue
        block = BOTTLE_BLOCK.format(root=CENTRAL_ROOT, tag=PLATFORM, sha=e["sha256"])
        if re.search(r"bottle\s+do", t):
            t2 = re.sub(r"bottle\s+do.*?\n\s*end", block.strip("\n"), t, count=1, flags=re.S)
        else:
            # 无 bottle 块：插到 class 声明后的合适位置（depends_on 之后 / url 之前皆可，这里放 class 首行后）
            t2 = re.sub(r"(^\s*class\s+\w+\s*<\s*Formula\s*$)",
                        r"\1\n" + block.rstrip("\n"), t, count=1, flags=re.M)
        if t2 != t:
            open(f, "w", encoding="utf-8", newline="\n").write(t2)
            print(f"normalized {f}")
        else:
            print(f"unchanged {f}")


if __name__ == "__main__":
    main()
