#!/usr/bin/env bash
# libserialport 0.1.2 —— 跨平台串口访问库（总线舵机/雷达/GPS 等 UART 外设）。
# 入口：contrib/build-from-source.sh（注入 CC/STAGE/PREFIX 等）
# 注意：GitHub tag 解包目录为 libserialport-libserialport-<ver>，需要摆正。
set -euo pipefail

./configure --host="$HOSTTriplet" --prefix="$PREFIX" --disable-examples CFLAGS="$CFLAGS"
make -j"$JOBS"
make DESTDIR="$STAGE_PARENT" install

find "$STAGE" -type f \( -name '*.a' -o -name '*.la' \) -delete
find "$STAGE" -type f | while read -r f; do
  file "$f" | grep -q ELF && "$STRIP" --strip-unneeded "$f" 2>/dev/null || true
done
file "$STAGE/lib/libserialport.so" | grep -q RISC-V || { echo "not riscv64!" >&2; exit 1; }
