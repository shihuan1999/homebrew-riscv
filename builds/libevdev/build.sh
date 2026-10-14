#!/usr/bin/env bash
# libevdev 1.13.4 —— /dev/input 事件封装（手柄/遥控器遥测输入）。
# 入口：contrib/build-from-source.sh（注入 CC/STAGE/PREFIX 等）
# 注意：--host 下 configure 找不到 pkg-config，需 PKG_CONFIG 指向宿主实现。
set -euo pipefail
export PKG_CONFIG="${PKG_CONFIG:-/usr/bin/pkg-config}"

./configure --host="$HOSTTriplet" --prefix="$PREFIX" \
  --disable-tests --disable-documentation CFLAGS="$CFLAGS"
make -j"$JOBS"
make DESTDIR="$STAGE_PARENT" install

find "$STAGE" -type f \( -name '*.a' -o -name '*.la' \) -delete
find "$STAGE" -type f | while read -r f; do
  file "$f" | grep -q ELF && "$STRIP" --strip-unneeded "$f" 2>/dev/null || true
done
file "$STAGE/lib/libevdev.so.2" | grep -q RISC-V || { echo "not riscv64!" >&2; exit 1; }
