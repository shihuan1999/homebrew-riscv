#!/usr/bin/env bash
# libgpiod 2.3.1 —— GPIO 字符设备库与工具（机器人 GPIO 控制）。
# 入口：contrib/build-from-source.sh（注入 CC/STAGE/PREFIX 等）
# 注意：2.3.x 仅支持 meson（>=0.64）构建；cross 文件值必须用单引号（meson DSL 语法）。
set -euo pipefail

cat > "$WORK/cross.ini" <<EOF
[binaries]
c = '$CC'
cpp = '$CXX'
ar = '$AR'
strip = '$STRIP'

[host_machine]
system = 'linux'
cpu_family = 'riscv64'
cpu = 'riscv64'
endian = 'little'
EOF

meson setup builddir --cross-file "$WORK/cross.ini" --prefix="$PREFIX" \
  -Dtools=enabled -Dgpioset-interactive=disabled -Dtests=disabled \
  -Dexamples=disabled -Dbindings-cxx=disabled -Dbindings-glib=disabled \
  -Ddbus=disabled -Dintrospection=disabled -Dprofiling=false

ninja -C builddir -j"$JOBS"
DESTDIR="$STAGE_PARENT" ninja -C builddir install

find "$STAGE" -type f \( -name '*.a' -o -name '*.la' \) -delete
find "$STAGE" -type f | while read -r f; do
  file "$f" | grep -q ELF && "$STRIP" --strip-unneeded "$f" 2>/dev/null || true
done
file "$STAGE/bin/gpiodetect" | grep -q RISC-V || { echo "not riscv64!" >&2; exit 1; }
