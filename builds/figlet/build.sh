#!/usr/bin/env bash
# figlet 2.2.5 —— Makefile 型小工程的典型配方。
# 入口：contrib/build-from-source.sh（注入 CC/STAGE/PREFIX 等）
set -euo pipefail

FONTDIR="$PREFIX/share/figlet"

# musl 没有 glibc sys/cdefs.h 的 __BEGIN_DECLS/__END_DECLS（figlet utf8.h 依赖），
# 老代码 K&R 声明需要 gnu89（GCC14+ 默认 C 标准过新）
EXTRA="-std=gnu89 -D__BEGIN_DECLS= -D__END_DECLS="

# 注意：figlet 的 Makefile 自带 -DDEFAULTFONTDIR=\"$(DEFAULTFONTDIR)\" 且排在
# CFLAGS 之后会覆盖同名宏，必须直接传 make 变量而不是塞进 CFLAGS
make figlet \
  CC="$CC" LD="$CC" \
  DEFAULTFONTDIR="$FONTDIR" DEFAULTFONTFILE="standard" \
  CFLAGS="$CFLAGS $EXTRA" \
  -j"$JOBS"

mkdir -p "$STAGE/bin" "$STAGE/share/figlet" "$STAGE/share/man/man6"
install -m 755 figlet "$STAGE/bin/figlet"
install -m 644 fonts/*.flf "$STAGE/share/figlet/"
install -m 644 fonts/*.flc "$STAGE/share/figlet/" 2>/dev/null || true
install -m 644 figlet.6 "$STAGE/share/man/man6/" 2>/dev/null || true

# 自证：产物必须是 riscv64
file "$STAGE/bin/figlet" | grep -q RISC-V || { echo "not a riscv64 binary!" >&2; exit 1; }
"$STRIP" "$STAGE/bin/figlet" || true
