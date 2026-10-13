#!/bin/sh
# harmonybrew 设备端一键引导（K3 pico / OpenHarmony 6.1 / riscv64 musl）。
# 设备上执行（需要能访问 GitHub；不能访问外网的设备请用 hdc 预置方式，见 CONTRIBUTING.md）：
#   . <(curl -fsSL https://raw.githubusercontent.com/shihuan1999/homebrew-riscv/main/contrib/install.sh)
# 或下载后:  sh install.sh
# 产物：/data/harmonybrew（brew 树 + portable-ruby + tap），/data/hbrew-home（HOME）
set -e

PREFIX=${HBREW_PREFIX:-/data/harmonybrew}
HOME_DIR=${HBREW_HOME:-/data/hbrew-home}
DL=${HBREW_DL:-/data/hbrew-pkgs}
TAP_REPO=shihuan1999/homebrew-riscv
REL=https://github.com/$TAP_REPO/releases/download/bootstrap-v1

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

fetch "$REL/harmonybrew-riscv64.tar.gz" harmonybrew-riscv64.tar.gz
fetch "$REL/portable-ruby-4.0.3.riscv64_ohos.bottle.tar.gz" portable-ruby.bottle.tar.gz
fetch "$REL/tap-latest.tar.gz" tap-latest.tar.gz

# 1) brew 树
tar xzf harmonybrew-riscv64.tar.gz -C "$PREFIX"
# 2) vendor portable-ruby
mkdir -p "$PREFIX/Library/Homebrew/vendor/portable-ruby"
tar xzf portable-ruby.bottle.tar.gz -C "$PREFIX/Library/Homebrew/vendor/portable-ruby"
ruby_ver=$(ls "$PREFIX/Library/Homebrew/vendor/portable-ruby" | head -1)
ln -sfn "$ruby_ver/current" "$PREFIX/Library/Homebrew/vendor/portable-ruby/current" 2>/dev/null || true
# 3) tap
mkdir -p "$PREFIX/Library/Taps/hbrew"
rm -rf "$PREFIX/Library/Taps/hbrew/homebrew-riscv"
tar xzf tap-latest.tar.gz -C "$PREFIX/Library/Taps/hbrew/"
mv "$PREFIX/Library/Taps/hbrew/homebrew-riscv" "$PREFIX/Library/Taps/hbrew/homebrew-riscv" 2>/dev/null || true
# 4) 空壳 core tap，防 brew 自动 clone 官方源
mkdir -p "$PREFIX/Library/Taps/harmonybrew/homebrew-core"
git() { :; } # 设备无 git 时禁用外部 clone；如已装 portable-git 会自动可用

# 5) 环境
cat > "$PREFIX/hbrew-env.sh" <<EOF
export HOMEBREW_PREFIX="$PREFIX"
export HOMEBREW_HOME="\$HOMEBREW_PREFIX"
export HOME="$HOME_DIR"
export PATH="\$HOMEBREW_PREFIX/bin:/system/bin:/bin:\$PATH"
export HOMEBREW_NO_INSTALL_FROM_API=1
export HOMEBREW_NO_AUTO_UPDATE=1
export HOMEBREW_NO_INSTALL_CLEANUP=1
export HOMEBREW_BOTTLE_DOMAIN=https://github.com/$TAP_REPO/releases/download/bottles
export SSL_CERT_FILE="\$HOMEBREW_PREFIX/etc/ssl/cacert.pem"
export CURL_CA_BUNDLE="\$SSL_CERT_FILE"
export LD_LIBRARY_PATH="\$HOMEBREW_PREFIX/lib:\${LD_LIBRARY_PATH:-}"
EOF
mkdir -p "$HOME_DIR/.cache/Homebrew/api" "$PREFIX/etc/services" "$PREFIX/var/services/enabled" "$PREFIX/var/log" "$PREFIX/var/run"

. "$PREFIX/hbrew-env.sh"
brew --version || { echo "brew bootstrap failed" >&2; exit 1; }
echo "OK: harmonybrew @ $PREFIX"
echo "用法: . $PREFIX/hbrew-env.sh && brew install hbrew/riscv/<name>"
