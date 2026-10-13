#!/usr/bin/env bash
# 重建 tap 快照与索引（publish 工作流每次发布后调用，也可手动执行）：
#   tap-latest.tar.gz —— 设备端离线初始化用的 tap 快照
#   index.json        —— name/version/deps/desc/入口，供设备端 brew search/脚本消费
set -euo pipefail
cd "$(dirname "$0")/.."

rm -f tap-latest.tar.gz
tar czf tap-latest.tar.gz Formula/ README.md OHOS-PORTS.md 2>/dev/null || tar czf tap-latest.tar.gz Formula/ README.md
echo "tap-latest.tar.gz: $(du -h tap-latest.tar.gz | cut -f1)"

PYTHON=$(command -v python3 || command -v python)
$PYTHON - <<'EOF'
import glob, json, re, os
index = []
for f in sorted(glob.glob("Formula/*/*.rb")):
    t = open(f, encoding="utf-8", errors="replace").read()
    def g(p, default=None):
        m = re.search(p, t, re.M)
        return m.group(1) if m else default
    entry = {
        "name": (g(r"^\s*class\s+(\w+)") or "").lower(),
        "version": g(r'^\s*version\s+"([^"]+)"') or "",
        "desc": g(r'^\s*desc\s+"([^"]+)"') or "",
        "homepage": g(r'^\s*homepage\s+"([^"]+)"') or "",
        "deps": re.findall(r'^\s*depends_on\s+"([^"]+)"', t, re.M),
        "formula": f.replace("\\", "/"),
        "bottled": bool(re.search(r"riscv64_ohos:\s*\"[0-9a-f]{64}\"", t)),
    }
    if entry["name"]:
        index.append(entry)
json.dump({"count": len(index), "updated": __import__("time").strftime("%Y-%m-%dT%H:%M:%SZ", __import__("time").gmtime()), "packages": index},
          open("index.json", "w"), indent=1, ensure_ascii=False)
print(f"index.json: {len(index)} packages")
EOF
