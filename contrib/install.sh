#!/bin/sh
# harmonybrew 设备端一键引导 v2（K3 pico / OpenHarmony 6.x / riscv64 musl）。
# 设备上执行（需要能访问 GitHub；不能访问外网的设备请用 hdc 预置方式，见 CONTRIBUTING.md）：
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/shihuan1999/homebrew-riscv/main/contrib/install.sh)"
# 或下载后:  sh install.sh
#
# v2 修正（2026-11-05，真机实测校准）：
#   · tap 解包到 Library/Taps/hbrew/homebrew-riscv/（旧版解到 hbrew/ 根，
#     brew 识别成 hbrew/Formula 而非 hbrew/riscv，install 名字对不上）
#   · 补装 portable-git（brew 硬依赖，进 PATH）
#   · bin/brew 环境白名单补丁（透传 SSL_CERT_FILE 等，否则 curl 报
#     "unable to get local issuer certificate"）
#   · cacert.pem 单独下发（bootstrap brew 树内不带）
#   · hbrew-env.sh 与镜像种子版对齐（CELLAR/REPOSITORY/GIT_SSL_CAINFO/去遥测）
# 产物：/data/harmonybrew（brew 树 + portable-ruby/git + tap），/data/hbrew-home（HOME）
set -e

PREFIX=${HBREW_PREFIX:-/data/harmonybrew}
HOME_DIR=${HBREW_HOME:-/data/hbrew-home}
DL=${HBREW_DL:-/data/hbrew-pkgs}
TAP_REPO=shihuan1999/homebrew-riscv
REL=https://github.com/$TAP_REPO/releases/download/bootstrap-v1
BOTTLES=https://github.com/$TAP_REPO/releases/download/bottles
RUBY_VER=4.0.3
GIT_VER=2.54.0

mkdir -p "$PREFIX" "$HOME_DIR" "$DL"
cd "$DL"

fetch() { # fetch <url> <file>
  [ -s "$2" ] && return 0
  echo "downloading $2 ..."
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL --retry 3 -o "$2" "$1"
  elif command -v wget >/dev/null 2>&1; then
    wget -q -O "$2" "$1"
  else
    echo "need curl or wget on device" >&2; return 1
  fi
}

# 先拿 CA 证书（设备系统 curl 无 GitHub CA，首次用 -k 仅取证书本体=信任引导），
# 之后所有下载都在验证的 TLS 下进行。
if [ ! -s cacert.pem ]; then
  if command -v curl >/dev/null 2>&1; then
    curl -fkSL --retry 3 -o cacert.pem "$REL/cacert.pem"
  else
    wget -q -O cacert.pem --no-check-certificate "$REL/cacert.pem"
  fi
fi
[ -s cacert.pem ] || { echo "failed to fetch cacert.pem" >&2; exit 1; }
export SSL_CERT_FILE="$PWD/cacert.pem" SSL_CERT_DIR="$PWD"
export CURL_CA_BUNDLE="$PWD/cacert.pem" GIT_SSL_CAINFO="$PWD/cacert.pem"

fetch "$REL/harmonybrew-riscv64.tar.gz" harmonybrew-riscv64.tar.gz
fetch "$REL/portable-ruby-$RUBY_VER.riscv64_ohos.bottle.tar.gz" portable-ruby.bottle.tar.gz
fetch "$BOTTLES/portable-git-$GIT_VER.riscv64_ohos.bottle.tar.gz" portable-git.bottle.tar.gz
fetch "$REL/tap-latest.tar.gz" tap-latest.tar.gz

# 1) brew 树
tar xzf harmonybrew-riscv64.tar.gz -C "$PREFIX"
# 2) vendor portable-ruby / portable-git
#    （瓶顶层是 <name>/<ver>/；toybox tar 的 --strip-components 会弄断瓶内硬链接，
#     所以先整包解到临时目录再 mv 版本目录就位）
untap_vendor() { # untap_vendor <name> <ver>
  mkdir -p "$PREFIX/Library/Homebrew/vendor/$1" "$PREFIX/Library/Homebrew/vendor/$1.tmp"
  tar xzf "$1.bottle.tar.gz" -C "$PREFIX/Library/Homebrew/vendor/$1.tmp"
  mv "$PREFIX/Library/Homebrew/vendor/$1.tmp/$1/$2" "$PREFIX/Library/Homebrew/vendor/$1/"
  rm -rf "$PREFIX/Library/Homebrew/vendor/$1.tmp"
  ln -sfn "$2" "$PREFIX/Library/Homebrew/vendor/$1/current"
}
untap_vendor portable-ruby "$RUBY_VER"
untap_vendor portable-git "$GIT_VER"
# 3) CA 证书
mkdir -p "$PREFIX/etc/ssl"
cp cacert.pem "$PREFIX/etc/ssl/cacert.pem"
# 4) tap 解包到 hbrew/homebrew-riscv（tap 名 = hbrew/riscv）
mkdir -p "$PREFIX/Library/Taps/hbrew/homebrew-riscv"
tar xzf tap-latest.tar.gz -C "$PREFIX/Library/Taps/hbrew/homebrew-riscv/"
# 5) 空壳 core tap，防 brew 自动 clone 官方源
mkdir -p "$PREFIX/Library/Taps/harmonybrew/homebrew-core"

# 6) bin/brew 环境白名单补丁（透传 CA/代理变量；幂等）
if ! grep -q 'SSL_CERT_FILE CURL_CA_BUNDLE' "$PREFIX/bin/brew"; then
  sed -i 's|^  http_proxy https_proxy ftp_proxy no_proxy all_proxy HTTPS_PROXY FTP_PROXY ALL_PROXY$|  http_proxy https_proxy ftp_proxy no_proxy all_proxy HTTPS_PROXY FTP_PROXY ALL_PROXY\n  SSL_CERT_FILE SSL_CERT_DIR CURL_CA_BUNDLE GIT_SSL_CAINFO|' "$PREFIX/bin/brew"
  grep -q 'SSL_CERT_FILE CURL_CA_BUNDLE' "$PREFIX/bin/brew" || {
    echo "WARN: bin/brew whitelist patch did not match (brew may filter SSL env)" >&2
  }
fi

# 7) 环境（与镜像种子版 hbrew-env.sh 对齐）
cat > "$PREFIX/hbrew-env.sh" <<EOF
export HOMEBREW_PREFIX="$PREFIX"
export HOMEBREW_HOME="$PREFIX"
export HOMEBREW_CELLAR="$PREFIX/Cellar"
export HOMEBREW_REPOSITORY="$PREFIX"
export HOME="$HOME_DIR"
export PATH="$PREFIX/bin:$PREFIX/Library/Homebrew/vendor/portable-git/current/bin:/system/bin:/bin:\$PATH"
export HOMEBREW_NO_INSTALL_FROM_API=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1
export HOMEBREW_BOTTLE_DOMAIN="$BOTTLES"
export SSL_CERT_FILE="$PREFIX/etc/ssl/cacert.pem"
export SSL_CERT_DIR="$PREFIX/etc/ssl"
export CURL_CA_BUNDLE="$PREFIX/etc/ssl/cacert.pem"
export GIT_SSL_CAINFO="$PREFIX/etc/ssl/cacert.pem"
export LD_LIBRARY_PATH="$PREFIX/lib:\${LD_LIBRARY_PATH:-}"
EOF
mkdir -p "$HOME_DIR/.cache/Homebrew/api" "$PREFIX/etc/services" "$PREFIX/var/services/enabled" "$PREFIX/var/log" "$PREFIX/var/run"

. "$PREFIX/hbrew-env.sh"
brew --version || { echo "brew bootstrap failed" >&2; exit 1; }
n=$(brew search '' 2>/dev/null | wc -l)
echo "OK: harmonybrew @ $PREFIX ($n formulae in tap)"
echo "用法: . $PREFIX/hbrew-env.sh && brew install hbrew/riscv/<name>"
