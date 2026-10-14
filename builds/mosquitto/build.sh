#!/usr/bin/env bash
# mosquitto 2.0.20 —— MQTT broker/客户端（机器人遥测与控制通道）。
# 入口：contrib/build-from-source.sh（注入 CC/STAGE/PREFIX 等）
# 依赖：cjson keg（头文件 + libcjson.so）；无 TLS 以保持 keg 自包含。
set -euo pipefail
CJSONDIR="${CJSONDIR:?}"   # cjson keg 根（include/ + lib/）

make -j"$JOBS" \
  WITH_DOCS=no WITH_TLS=no WITH_WEBSOCKETS=no WITH_STATIC_LIBS=no \
  CC="$CC" CXX="$CXX" AR="$AR" \
  CFLAGS="$CFLAGS -I$CJSONDIR/include -DHAVE_DECL_CJSON_BOOL" \
  LDFLAGS="-L$CJSONDIR/lib -Wl,-rpath,\$ORIGIN/../lib"

make DESTDIR="$STAGE_PARENT" prefix="$PREFIX" \
  WITH_DOCS=no WITH_TLS=no WITH_WEBSOCKETS=no install

find "$STAGE" -type f \( -name '*.a' -o -name '*.la' \) -delete
find "$STAGE" -type f | while read -r f; do
  file "$f" | grep -q ELF && "$STRIP" --strip-unneeded "$f" 2>/dev/null || true
done
file "$STAGE/sbin/mosquitto" | grep -q RISC-V || { echo "not riscv64!" >&2; exit 1; }
