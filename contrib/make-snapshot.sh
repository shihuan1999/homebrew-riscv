#!/usr/bin/env bash
# 重建 tap 快照与索引（publish 工作流每次发布后调用，也可手动执行）：
#   tap-latest.tar.gz —— 设备端离线初始化用的 tap 快照（只含 git 已提交文件）
#   index.json        —— name/version/deps/desc/入口，供设备端 brew search/脚本消费
# 修正记录（2026-11-05）：
#   · index.json 的 name 改从 formula 文件名取（此前取 class 名，会把
#     python@3.11 mangle 成 pythonat311、agentstore-build mangle 成 agentstorebuild）；
#   · deps 剥掉 hbrew/riscv/ 等 tap 前缀，设备端按裸名即可解析依赖；
#   · tap-latest.tar.gz 改为只打包 git 已跟踪文件，避免把工作区未提交
#     formula（瓶未发布、URL 404）混进快照。
set -euo pipefail
cd "$(dirname "$0")/.."

rm -f tap-latest.tar.gz
if git rev-parse --is-inside-work-tree >/dev/null 2>&1 && [ -n "$(git ls-files Formula)" ]; then
  # git 工作树可用：只打包已提交/已 add 的文件（CI 干净检出与本地面脏树都成立）
  git ls-files -z -- Formula README.md OHOS-PORTS.md | tar czf tap-latest.tar.gz --null -T -
else
  tar czf tap-latest.tar.gz Formula/ README.md OHOS-PORTS.md 2>/dev/null || tar czf tap-latest.tar.gz Formula/ README.md
fi
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
    # name 以 formula 文件名为准（brew 的规范名称），class 名仅作回退
    name = os.path.splitext(os.path.basename(f))[0]
    deps = []
    for d in re.findall(r'^\s*depends_on\s+"([^"]+)"', t, re.M):
        # 剥 tap 前缀（hbrew/riscv/node -> node），保留裸名
        deps.append(d.rsplit("/", 1)[-1])
    entry = {
        "name": name,
        "version": g(r'^\s*version\s+"([^"]+)"') or "",
        "desc": g(r'^\s*desc\s+"([^"]+)"') or "",
        "homepage": g(r'^\s*homepage\s+"([^"]+)"') or "",
        "deps": deps,
        "formula": f.replace("\\", "/"),
        "bottled": bool(re.search(r"riscv64_ohos:\s*\"[0-9a-f]{64}\"", t)),
    }
    index.append(entry)
json.dump({"count": len(index), "updated": __import__("time").strftime("%Y-%m-%dT%H:%M:%SZ", __import__("time").gmtime()), "packages": index},
          open("index.json", "w"), indent=1, ensure_ascii=False)
print(f"index.json: {len(index)} packages")
EOF
