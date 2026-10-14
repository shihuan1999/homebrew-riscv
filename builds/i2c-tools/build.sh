#!/usr/bin/env bash
# i2c-tools 4.4 —— I2C 总线探测/读写工具（传感器、舵机控制板通信）。
# 入口：contrib/build-from-source.sh（注入 CC/STAGE/PREFIX 等）
set -euo pipefail

make -j"$JOBS" CC="$CC" EXTRA_CFLAGS="$CFLAGS" \
  LDFLAGS="-Wl,-rpath,\$ORIGIN/../lib" PREFIX="$PREFIX" all

make DESTDIR="$STAGE_PARENT" PREFIX="$PREFIX" install

find "$STAGE" -type f \( -name '*.a' -o -name '*.la' \) -delete
find "$STAGE" -type f | while read -r f; do
  file "$f" | grep -q ELF && "$STRIP" --strip-unneeded "$f" 2>/dev/null || true
done
file "$STAGE/sbin/i2cdetect" | grep -q RISC-V || { echo "not riscv64!" >&2; exit 1; }
