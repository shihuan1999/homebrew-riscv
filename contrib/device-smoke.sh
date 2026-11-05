#!/usr/bin/env bash
# 设备端冒烟 v2：网关机（有 hdc）上运行，把 bottle 预置进设备 brew 缓存后
# 真实安装 + 可执行冒烟。不要求设备能访问外网（bottle 由网关侧下载/取自构建产物）。
#
# v2 修正（2026-11-05，真机实测校准）：
#   · 缓存路径：brew 实际读 <cache>/downloads/sha256(url)--file（旧版漏了 downloads/）
#   · brew test → 可执行冒烟（tap 内 formula 无 test 块，brew test 必挂）
#   · Windows 网关兼容：MSYS_NO_PATHCONV=1（hdc file send 的 /data/... 不被改写），
#     python3 缺失时回退 python
#   · 设备端已装同名包时先卸载，保证干净状态
# 用法: device-smoke.sh <formula-name> [hdc-target] [--keep]
set -euo pipefail

NAME=${1:?usage: device-smoke.sh <formula-name> [hdc-target] [--keep]}
TGT=${2:-}
KEEP=${3:-}
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HDC="hdc"; [ -n "$TGT" ] && HDC="hdc -t $TGT"
# Windows/git-bash 网关：阻止 MSYS 把 /data/... 改写成盘符路径
export MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='*'
PY=$(command -v python3 || command -v python)

# 1) 定位 bottle：本地 out/（紧接 build-source）> 中央 release > formula root_url
f="$REPO_ROOT/Formula/${NAME:0:1}/$NAME.rb"
[ -f "$f" ] || f="$REPO_ROOT/Formula/$NAME.rb"
[ -f "$f" ] || { echo "formula not found: $NAME" >&2; exit 2; }
read -r VER ROOT_URL SHAB <<<"$($PY - "$f" <<'PY'
import re, sys
t = open(sys.argv[1], encoding="utf-8", errors="replace").read()
ver = (re.search(r'^\s*version\s+"([^"]+)"', t, re.M) or [None,""])[1]
ru = (re.search(r'bottle\s+do.*?root_url\s+"([^"]+)"', t, re.S) or [None,""])[1]
sha = (re.search(r"riscv64_ohos:\s*\"([0-9a-f]{64})\"", t) or [None,""])[1]
print(ver, ru or "-", sha or "-")
PY
)"
[ -n "$VER" ] || { echo "cannot parse formula $NAME" >&2; exit 2; }
ASSET="$NAME-$VER.riscv64_ohos.bottle.tar.gz"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
if [ -f "out/$ASSET" ]; then
  cp "out/$ASSET" "$TMP/$ASSET"; SRC=local-build
elif [ "$ROOT_URL" != "-" ]; then
  curl -fsSL --retry 3 -o "$TMP/$ASSET" "$ROOT_URL/$ASSET"; SRC="$ROOT_URL"
else
  echo "no bottle available for $NAME" >&2; exit 2
fi
echo "bottle: $ASSET (from $SRC)"

# 2) 校验 sha256 + 结构
if [ "$SHAB" != "-" ]; then
  echo "$SHAB  $TMP/$ASSET" | sha256sum -c - || { echo "sha mismatch" >&2; exit 3; }
fi
"$PY" "$REPO_ROOT/contrib/validate_bottle.py" "$TMP/$ASSET" --name "$NAME" --version "$VER"

# 3) 推到设备并按 brew 缓存命名规则预置：<cache>/downloads/sha256(url)--filename
URL="$ROOT_URL/$ASSET"
CACHE_NAME=$(printf '%s' "$URL" | sha256sum | cut -d' ' -f1)--$ASSET
DEV_CACHE=$($HDC shell ". /data/harmonybrew/hbrew-env.sh && brew --cache" 2>/dev/null | tr -d '\r')
[ -n "$DEV_CACHE" ] || DEV_CACHE=/data/hbrew-home/.cache/Homebrew
echo "pushing to device cache: $DEV_CACHE/downloads/$CACHE_NAME"
$HDC shell "mkdir -p '$DEV_CACHE/downloads'" >/dev/null
$HDC file send "$TMP/$ASSET" "/data/bsmk.tar" >/dev/null
$HDC shell "mv /data/bsmk.tar '$DEV_CACHE/downloads/$CACHE_NAME'"

# 4) 设备端：干净状态 → 安装 → 可执行冒烟
ENVSRC=". /data/harmonybrew/hbrew-env.sh"
echo "=== device: uninstall (clean state) ==="
$HDC shell "$ENVSRC; brew uninstall --formula --ignore-dependencies hbrew/riscv/$NAME 2>/dev/null || true"
echo "=== device: brew install ==="
$HDC shell "$ENVSRC; brew install --formula hbrew/riscv/$NAME 2>&1" || { echo "INSTALL FAILED: $NAME" >&2; exit 4; }
echo "=== device: smoke ==="
SMOKE_OUT=$($HDC shell "$ENVSRC && KEG=\$(ls -d \$HOMEBREW_CELLAR/$NAME/*/ 2>/dev/null | tail -1) && \
  echo \"keg:\$KEG\" && \
  BIN=\"\"; for d in bin sbin libexec; do for x in \"\$KEG\$d\"/*; do [ -f \"\$x\" ] && [ -x \"\$x\" ] && BIN=\"\$x\" && break 2; done; done; \
  if [ -n \"\$KEG\" ]; then \
    if [ -n \"\$BIN\" ]; then timeout 15 \"\$BIN\" --version 2>&1 | head -2 || timeout 15 \"\$BIN\" -h 2>&1 | head -2; \
    else echo \"keg-files:\$(find \"\$KEG\" -type f | wc -l)\"; fi; \
  else echo NO-KEG; fi" 2>&1 | tr -d '\r')
echo "$SMOKE_OUT"
echo "$SMOKE_OUT" | grep -q 'NO-KEG' && { echo "SMOKE FAILED: keg not created" >&2; exit 5; }
echo "$SMOKE_OUT" | grep -q '^keg:' || { echo "SMOKE FAILED: no keg report" >&2; exit 5; }

# 5) 收尾：默认卸载保持设备干净（--keep 保留）
if [ "$KEEP" != "--keep" ]; then
  $HDC shell "$ENVSRC; brew uninstall --formula --ignore-dependencies hbrew/riscv/$NAME >/dev/null 2>&1 || true"
fi
echo "SMOKE OK: $NAME $VER"
