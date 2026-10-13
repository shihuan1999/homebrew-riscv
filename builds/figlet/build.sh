#!/usr/bin/env bash
# figlet 2.2.5 —— Makefile 型小工程的典型配方。
# 入口：contrib/build-from-source.sh（注入 CC/STAGE/PREFIX 等）
set -euo pipefail

FONTDIR="$PREFIX/share/figlet"

make figlet \
  CC="$CC" \
  CFLAGS="$CFLAGS -DDEFAULTFONTDIR=\\\"$FONTDIR\\\" -DDEFAULTFONTFILE=\\\"standard.flf\\\"" \
  -j"$JOBS"

mkdir -p "$STAGE/bin" "$STAGE/share/figlet" "$STAGE/share/man/man6"
install -m 755 figlet "$STAGE/bin/figlet"
install -m 644 fonts/*.flf "$STAGE/share/figlet/"
install -m 644 fonts/*.flc "$STAGE/share/figlet/" 2>/dev/null || true
install -m 644 figlet.6 "$STAGE/share/man/man6/" 2>/dev/null || true

# 自证：产物必须是 riscv64
file "$STAGE/bin/figlet" | grep -q RISC-V || { echo "not a riscv64 binary!" >&2; exit 1; }
"$STRIP" "$STAGE/bin/figlet" || true
