#!/usr/bin/env bash
# 设备端冒烟：网关机（有 hdc）上运行，把 bottle 预置进设备 brew 缓存后
# 真实安装 + 测试。不要求设备能访问外网（bottle 由网关侧下载/取自构建产物）。
# 用法: device-smoke.sh <formula-name> [hdc-target]
set -euo pipefail

NAME=${1:?usage: device-smoke.sh <formula-name> [hdc-target]}
TGT=${2:-}
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HDC="hdc"; [ -n "$TGT" ] && HDC="hdc -t $TGT"

# 1) 定位 bottle：本地 out/（紧接 build-source）> 中央 release > formula root_url
f="$REPO_ROOT/Formula/${NAME:0:1}/$NAME.rb"
[ -f "$f" ] || f="$REPO_ROOT/Formula/$NAME.rb"
[ -f "$f" ] || { echo "formula not found: $NAME" >&2; exit 2; }
read -r VER ROOT_URL SHAB <<<"$(python3 - "$f" <<'PY'
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
if [ -f "out/$ASSET" ]; then
  cp "out/$ASSET" "$TMP/$ASSET"; SRC=local-build
elif [ "$ROOT_URL" != "-" ]; then
  curl -fsSL --retry 3 -o "$TMP/$ASSET" "$ROOT_URL/$ASSET"; SRC="$ROOT_URL"
else
  echo "no bottle available for $NAME" >&2; exit 2
fi
echo "bottle: $ASSET (from $SRC)"

# 2) 校验（如果 formula 带了 sha256 就强制比对）
if [ "$SHAB" != "-" ]; then
  echo "$SHAB  $TMP/$ASSET" | sha256sum -c - || { echo "sha mismatch" >&2; exit 3; }
fi
python3 "$REPO_ROOT/contrib/validate_bottle.py" "$TMP/$ASSET" --name "$NAME" --version "$VER"

# 3) 推到设备并按 brew 缓存命名规则预置（sha256(url)--filename）
URL="$ROOT_URL/$ASSET"
CACHE_NAME=$(printf '%s' "$URL" | sha256sum | cut -d' ' -f1)--$ASSET
DEV_CACHE=/data/hbrew-home/.cache/Homebrew
echo "pushing $CACHE_NAME to device"
$HDC shell "mkdir -p $DEV_CACHE" >/dev/null
$HDC file send "$TMP/$ASSET" "/data/bsmk.tar" >/dev/null
$HDC shell "mv /data/bsmk.tar '$DEV_CACHE/$CACHE_NAME'"

# 4) 设备端安装 + 测试
echo "=== device: brew install ==="
$HDC shell ". /data/harmonybrew/hbrew-env.sh 2>/dev/null || . /data/homebrew/hbrew-env.sh; \
  brew install --formula hbrew/riscv/$NAME 2>&1 || brew install --formula $NAME 2>&1"
echo "=== device: brew test ==="
$HDC shell ". /data/harmonybrew/hbrew-env.sh 2>/dev/null || . /data/homebrew/hbrew-env.sh; \
  brew test hbrew/riscv/$NAME 2>&1"
echo "=== device: bin smoke ==="
$HDC shell ". /data/harmonybrew/hbrew-env.sh 2>/dev/null || . /data/homebrew/hbrew-env.sh; \
  ls -l \$(brew --prefix)/bin/ | head -20; \
  command -v $NAME && $NAME --version 2>&1 | head -3 || true"
echo "SMOKE OK"
