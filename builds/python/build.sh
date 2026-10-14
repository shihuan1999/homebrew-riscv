#!/usr/bin/env bash
# python 3.12.14 —— CPython 交叉编译配方（musl riscv64，OHOS K3）。
# 入口：contrib/build-from-source.sh（注入 CC/STAGE/PREFIX 等）
# 关键点（详见 docs/harmonybrew-contribution-pipeline.md）：
#   1. 依赖库全部交叉编译后装进同一 ROOTFS，configure 用 --with-openssl 指向它；
#   2. CPPFLAGS/LDFLAGS 指向 ROOTFS；LDFLAGS 必须带 -Wl,-rpath-link（GNU ld 对
#      间接依赖不查 -L，readline→ncurses 会挂）；
#   3. CONFIG_SITE 提供 ac_cv_buggy_getaddrinfo=no 等交叉缓存变量；
#   4. ncurses 公共头必须齐（curses.h/ncurses_dll.h/unctrl.h/ncurses.h→curses.h），
#      否则 readline/_curses 静默跳过；
#   5. --with-build-python 需要 ≥3.12 的宿主 Python（本仓 CI 预置 py312host）；
#   6. 设备端 LD_PRELOAD lib/libriscvflush.so（musl 不导出 __riscv_flush_icache）；
#   7. 裁剪：test/ idlelib/ tkinter/ config-*/ include/、*.a、__pycache__。
set -euo pipefail

ROOTFS="${ROOTFS:?}"          # 交叉依赖 sysroot（zlib/openssl/bz2/xz/sqlite/libffi/ncurses/readline/expat）
BUILDPY="${BUILDPY:?}"        # 宿主 python3.12（--with-build-python）

./configure --host="$HOSTTriplet" --build=x86_64-linux-gnu \
  --prefix="$PREFIX" \
  --with-build-python="$BUILDPY" \
  --without-ensurepip \
  --with-openssl="$ROOTFS$PREFIX" \
  CONFIG_SITE="$CONFIG_SITE" \
  CPPFLAGS="-I$ROOTFS$PREFIX/include" \
  LDFLAGS="-L$ROOTFS$PREFIX/lib -Wl,-rpath-link,$ROOTFS$PREFIX/lib -Wl,-rpath,$PREFIX/lib"

make -j"$JOBS"
make DESTDIR="$STAGE_PARENT" install   # STAGE_PARENT 下产出 <name>/<version> keg

K="$STAGE"
rm -rf "$K/lib/python3.11" 2>/dev/null || true    # 防旧 rootfs 污染
rm -rf "$K/lib/python3.12/test" "$K/lib/python3.12/idlelib" \
       "$K/lib/python3.12/tkinter" "$K/lib/python3.12/turtledemo" \
       "$K/lib/python3.12"/config-* "$K/include"
find "$K" -name '*.a' -delete
find "$K" -name '__pycache__' -type d -exec rm -rf {} + 2>/dev/null || true
find "$K" -type f | while read -r f; do
  file "$f" | grep -q ELF && "$STRIP" --strip-unneeded "$f" 2>/dev/null || true
done

# __riscv_flush_icache shim（2 行 fence.i）与 env/pip 配置随 keg 分发
install -m 755 "$SCRIPTDIR/icacheflush.so" "$K/lib/libriscvflush.so"
install -m 644 "$SCRIPTDIR/pip.conf" "$K/etc/pip.conf"
install -m 755 "$SCRIPTDIR/python-env.sh" "$K/bin/python-env.sh"

file "$K/bin/python3.12" | grep -q RISC-V || { echo "not a riscv64 binary!" >&2; exit 1; }
