#!/usr/bin/env bash
# snode7（10.0.50.17）self-hosted runner 的源码构建入口。
# 用法: build-from-source.sh <name1,name2,...> <outdir>
# 对每个 <name>：
#   1. 从 Formula/<字母>/<name>.rb 解析 name/version/url/sha256
#   2. 下载（缓存到 ~/WorkSpace/harmonybrew-port/src）并解压源码
#   3. 在源码目录执行 builds/<name>/build.sh（配方随 PR 提交、已 review）
#      配方约定：cwd=源码目录，安装目标=$STAGE（keg 目录 <name>/<version>/），
#               交叉工具链通过 $CC/$CXX/$AR/$RANLIB/$STRIP/$HOST/$CFLAGS 注入
#   4. tar 出 <name>-<version>.riscv64_ohos.bottle.tar.gz + sha256
set -euo pipefail

NAMES=${1:?usage: build-from-source.sh <names-csv> <outdir>}
OUT=${2:?output dir}
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TC=${HBREW_TC:-$HOME/WorkSpace/spacemit-toolchain-linux-musl-x86_64-oh-20260630}
SRCCACHE=${HBREW_SRC_CACHE:-$HOME/WorkSpace/harmonybrew-port/src}
HOST=riscv64-unknown-linux-musl
JOBS=${HBREW_JOBS:-$(nproc)}
PREFIX=/data/harmonybrew   # 设备端 brew 前缀（bottle 内 baked 路径，与存量一致）

export PATH="$TC/bin:$PATH"
export CC=$HOST-gcc CXX=$HOST-g++ AR=$HOST-ar RANLIB=$HOST-ranlib STRIP=$HOST-strip
export CFLAGS="-O2 -pipe" CXXFLAGS="-O2 -pipe"
mkdir -p "$OUT" "$SRCCACHE"

probe_meta() { # $1=name -> prints "version|url|sha256"
  local f="$REPO_ROOT/Formula/${1:0:1}/$1.rb"
  [ -f "$f" ] || f="$REPO_ROOT/Formula/$1.rb"
  [ -f "$f" ] || { echo "formula for '$1' not found" >&2; exit 2; }
  python3 - "$f" <<'PY'
import re, sys
t = open(sys.argv[1], encoding="utf-8", errors="replace").read()
def g(p):
    m = re.search(p, t, re.M)
    return m.group(1) if m else ""
ver = g(r'^\s*version\s+"([^"]+)"')
url = g(r'^\s*url\s+"([^"]+)"')
sha = g(r'^\s*sha256\s+"([0-9a-fA-F]{64})"')
if not ver and url:
    import os
    m = re.search(r"v?(\d[\w.+-]*?)(?:\.tar\.(gz|xz|bz2)|\.tgz|/)?$", os.path.basename(url))
    ver = m.group(1) if m else ""
print(f"{ver}|{url}|{sha}")
PY
}

fetch_src() { # $1=url $2=basename
  local dest="$SRCCACHE/$2"
  [ -s "$dest" ] || {
    echo "downloading $1"
    # 优先走环境代理（http_proxy/https_proxy 由 runner 环境注入）；
    # 失败再试 HBREW_HTTPS_PROXY 显式代理
    curl -fsSL --retry 3 -o "$dest" "$1" \
      || { [ -n "${HBREW_HTTPS_PROXY:-}" ] && curl -fsSL --retry 3 --proxy "$HBREW_HTTPS_PROXY" -o "$dest" "$1"; }
  }
}

IFS=',' read -ra LIST <<< "$NAMES"
: > "$OUT/bottles.sha256.json"
echo "[" > "$OUT/bottles.sha256.json.tmp"
first=1
for name in "${LIST[@]}"; do
  name=$(echo "$name" | xargs); [ -n "$name" ] || continue
  meta=$(probe_meta "$name")
  ver=$(echo "$meta" | cut -d'|' -f1)
  url=$(echo "$meta" | cut -d'|' -f2)
  sha=$(echo "$meta" | cut -d'|' -f3)
  recipe="$REPO_ROOT/builds/$name/build.sh"
  [ -f "$recipe" ] || { echo "no recipe builds/$name/build.sh for '$name'" >&2; exit 3; }
  [ -n "$ver" ] || { echo "cannot resolve version for $name" >&2; exit 2; }

  work=$(mktemp -d /tmp/hbrew-$name.XXXXXX)
  stage="$work/$name/$ver"
  mkdir -p "$stage"

  base=$(basename "$url")
  fetch_src "$url" "$base"
  if [ -n "$sha" ]; then
    echo "$sha  $SRCCACHE/$base" | sha256sum -c - || { echo "source sha mismatch: $name" >&2; exit 4; }
  fi
  srcdir="$work/src"
  mkdir -p "$srcdir"
  case "$base" in
    *.tar.gz|*.tgz) tar xzf "$SRCCACHE/$base" -C "$srcdir" --strip-components=1 ;;
    *.tar.xz) tar xJf "$SRCCACHE/$base" -C "$srcdir" --strip-components=1 ;;
    *.tar.bz2) tar xjf "$SRCCACHE/$base" -C "$srcdir" --strip-components=1 ;;
    *) cp "$SRCCACHE/$base" "$srcdir/" ;;
  esac

  echo "=== building $name $ver (recipe: builds/$name/build.sh) ==="
  (
    cd "$srcdir"
    export STAGE="$stage" NAME="$name" VERSION="$ver" HOST PREFIX JOBS
    export CFLAGS CXXFLAGS CC CXX AR RANLIB STRIP
    bash "$recipe"
  ) > "$OUT/build-$name.log" 2>&1 || { tail -40 "$OUT/build-$name.log"; echo "build failed: $name (full log: $OUT/build-$name.log)" >&2; exit 5; }

  asset="$OUT/$name-$ver.riscv64_ohos.bottle.tar.gz"
  tar czf "$asset" -C "$work" "$name"
  h=$(sha256sum "$asset" | cut -d' ' -f1)
  echo "$h  $(basename "$asset")" > "$OUT/$name-$ver.riscv64_ohos.bottle.tar.gz.sha256"
  [ $first -eq 1 ] || echo "," >> "$OUT/bottles.sha256.json.tmp"
  first=0
  echo -n "  {\"name\": \"$name\", \"version\": \"$ver\", \"asset\": \"$(basename "$asset")\", \"sha256\": \"$h\"}" >> "$OUT/bottles.sha256.json.tmp"
  echo "OK $name-$ver -> $asset (sha256=$h)"
  rm -rf "$work"
done
echo "" >> "$OUT/bottles.sha256.json.tmp"
echo "]" >> "$OUT/bottles.sha256.json.tmp"
mv "$OUT/bottles.sha256.json.tmp" "$OUT/bottles.sha256.json"
