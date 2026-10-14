#!/usr/bin/env bash
# cjson 1.7.18 —— cJSON（mosquitto 依赖的 JSON 解析库）。
# 入口：contrib/build-from-source.sh（注入 CC/STAGE/PREFIX 等）
# 注意：cmake DESTDIR 安装落在 stage/usr 下，需摆平到 keg 根。
set -euo pipefail

mkdir -p build && cd build
cmake -DCMAKE_C_COMPILER="$CC" -DCMAKE_SYSTEM_NAME=Linux \
  -DCMAKE_SYSTEM_PROCESSOR=riscv64 -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DENABLE_TESTING=OFF -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_AND_STATIC_LIBS=ON ..
make -j"$JOBS"
make DESTDIR="$STAGE_PARENT/stage" install

cd "$STAGE_PARENT/stage"
if [ -d usr ]; then mv usr/include "$STAGE_PARENT/include"; mv usr/lib "$STAGE_PARENT/lib"; rm -rf usr;
else mv include "$STAGE_PARENT/include"; mv lib "$STAGE_PARENT/lib"; fi
cd "$STAGE_PARENT" && rm -rf stage lib/cmake
ln -sf libcjson.so.1.7.18 lib/libcjson.so.1
ln -sf libcjson.so.1 lib/libcjson.so

find "$STAGE_PARENT" -type f \( -name '*.a' -o -name '*.la' \) -delete
file "$STAGE_PARENT/lib/libcjson.so.1.7.18" | grep -q RISC-V || { echo "not riscv64!" >&2; exit 1; }
