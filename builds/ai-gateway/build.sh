#!/usr/bin/env bash
# ai-gateway 3.0.0 — 端侧 AI 网关（网关 + 视觉 worker + 语音 worker）
#
# 入口：contrib/build-from-source.sh（注入 CC/CXX/STAGE/PREFIX/JOBS 等）。
# 这是真实的交叉编译配方：三个守护进程在这里从源码编出 riscv64 产物，
# 脚本/配置/内核数据随后按 keg 布局装进 $STAGE。
#
# 链接前提（设备镜像自带，不打进 keg）：
#   libonnxruntime.so.1  SpaceMiT EP 版 ONNX Runtime
#   libspacemit_ep.so    NPU 执行器
#   libc++_shared.so     OHOS libc++
#   libspert.so.1        spine 运行时
set -euo pipefail

SRC="$PWD"
STAGE="${STAGE:?STAGE not set}"
JOBS="${JOBS:-$(nproc)}"
CXX="${CXX:?CXX not set}"

die() { echo "ai-gateway: $*" >&2; exit 1; }

echo "== ai-gateway build =="
echo "   compiler : $CXX"
echo "   stage    : $STAGE"

# --- toolchain support dirs --------------------------------------------------
# Tap runner exports these for K3 builds; the defaults match snode7 so a plain
# contrib/build-from-source.sh run works too.
TC="${SPACEMIT_TC:-/home/heshihuan/WorkSpace/spacemit-toolchain-linux-musl-x86_64-oh-20260630}"
OHOS_SDK="${OHOS_SDK:-/home/heshihuan/WorkSpace/oh6.1/prebuilts/ohos-sdk/linux/23/native}"
ORT_EP_LIB="${ORT_EP_LIB:-/home/heshihuan/WorkSpace/oh6.1/device/soc/spacemit/common/hardware/ort-ep/lib}"
ORT_INC="${ORT_INC:-/home/heshihuan/WorkSpace2/ohos-ai-stack/spacemit-ort.riscv64.2.0.2/include}"

[ -d "$ORT_EP_LIB" ] || die "system onnxruntime/EP dir not found: $ORT_EP_LIB"
[ -d "$ORT_INC" ]    || die "onnxruntime headers not found: $ORT_INC"

# sherpa-onnx static archives for the voice front-end. They must be built with
# the same libc++ toolchain as the system ORT; see share/ai-gateway/
# build_sherpa_ep.sh. Fail loudly rather than ship a broken audio worker.
SHERPA_EP="${SHERPA_EP:-/home/heshihuan/WorkSpace2/ohos-ai-stack/sherpa-src/build-ohos-rv64-ep}"
SHERPA_CAPI="${SHERPA_SRC_ROOT:-/home/heshihuan/WorkSpace2/ohos-ai-stack/sherpa-src}/sherpa-onnx/c-api"
[ -d "$SHERPA_EP/lib" ] || die "sherpa-onnx tree missing: $SHERPA_EP
     build it with share/ai-gateway/build_sherpa_ep.sh first (see AI-GATEWAY-V3.md)"

# --- flags -------------------------------------------------------------------
CFLAGS="-O2 -fPIE -fno-omit-frame-pointer -std=c++17 -Isrc"
LDFLAGS="-pie -pthread"
# Resolve the image's DSOs at link time; --allow-shlib-undefined is required
# because libonnxruntime.so references pthread_setaffinity_np, which OHOS libc
# does not export.
LINK_IMG="-Wl,-rpath-link,$ORT_EP_LIB -Wl,-rpath,/system/lib64 -Wl,--allow-shlib-undefined"

GATEWAY_SRCS="src/util.cpp src/log.cpp src/json.cpp src/http.cpp src/sched.cpp \
src/llama_mgr.cpp src/vision.cpp src/spine_kernels.cpp src/pipeline.cpp \
src/tools.cpp src/agent.cpp src/gateway.cpp src/gateway_handlers.cpp \
src/gateway_llm.cpp src/gateway_agent.cpp src/main.cpp"

WORKER_SRCS="src/util.cpp src/log.cpp src/json.cpp src/http.cpp \
src/vision_session.cpp src/vision_worker_main.cpp"

AUDIO_SRCS="src/util.cpp src/log.cpp src/json.cpp src/http.cpp src/audio_io.cpp \
src/sherpa_engine.cpp src/voice_loop.cpp src/audio_worker_main.cpp"

mkdir -p "$STAGE/bin"

# --- spine-gateway -----------------------------------------------------------
echo "-- spine-gateway"
# shellcheck disable=SC2086
"$CXX" $CFLAGS $LDFLAGS \
    ${SPERT_INC:+-I$SPERT_INC} \
    $GATEWAY_SRCS \
    ${SPERT_LIB:+-L$SPERT_LIB} -lspert \
    $LINK_IMG \
    -o "$STAGE/bin/spine-gateway" \
    || die "spine-gateway link failed (needs libspert; set SPERT_LIB/SPERT_INC)"

# --- vision-worker -----------------------------------------------------------
echo "-- vision-worker"
# shellcheck disable=SC2086
"$CXX" $CFLAGS $LDFLAGS -I"$ORT_INC" \
    $WORKER_SRCS \
    -L"$ORT_EP_LIB" -lonnxruntime \
    $LINK_IMG \
    -o "$STAGE/bin/vision-worker" \
    || die "vision-worker link failed"

# --- audio-worker ------------------------------------------------------------
echo "-- audio-worker"
# shellcheck disable=SC2086
"$CXX" $CFLAGS $LDFLAGS -I"$SHERPA_CAPI" \
    $AUDIO_SRCS \
    "$SHERPA_EP/lib/libsherpa-onnx-c-api.a" \
    "$SHERPA_EP/lib/libsherpa-onnx-core.a" \
    "$SHERPA_EP/lib/libsherpa-onnx-fst.a" \
    "$SHERPA_EP/lib/libsherpa-onnx-fstfar.a" \
    "$SHERPA_EP/lib/libsherpa-onnx-kaldifst-core.a" \
    "$SHERPA_EP/lib/libkaldi-decoder-core.a" \
    "$SHERPA_EP/lib/libkaldi-native-fbank-core.a" \
    "$SHERPA_EP/lib/libpiper_phonemize.a" \
    "$SHERPA_EP/lib/libespeak-ng.a" \
    "$SHERPA_EP/lib/libssentencepiece_core.a" \
    "$SHERPA_EP/lib/libucd.a" \
    -L"$ORT_EP_LIB" -lonnxruntime \
    -L"$OHOS_SDK/sysroot/usr/lib/riscv64-linux-ohos" -lrawfile.z -lhilog_ndk.z \
    $LINK_IMG \
    -lpthread -ldl -lm \
    -o "$STAGE/bin/audio-worker" \
    || die "audio-worker link failed"

# --- scripts, config, kernels ------------------------------------------------
echo "-- data files"
mkdir -p "$STAGE/etc/ai-gateway" "$STAGE/var/ai-gateway/kernels" \
         "$STAGE/share/ai-gateway" "$STAGE/libexec"

install -m 755 bin/ai-gateway            "$STAGE/bin/ai-gateway"
install -m 644 etc/ai-gateway/gateway.json "$STAGE/etc/ai-gateway/gateway.json"
install -m 755 libexec/restart.sh        "$STAGE/libexec/restart.sh"

cp -R share/ai-gateway/src     "$STAGE/share/ai-gateway/"
cp -R share/ai-gateway/patches "$STAGE/share/ai-gateway/"
install -m 644 share/ai-gateway/AI-GATEWAY-V3.md   "$STAGE/share/ai-gateway/"
install -m 755 share/ai-gateway/build_gateway.sh   "$STAGE/share/ai-gateway/"
install -m 755 share/ai-gateway/build_sherpa_ep.sh "$STAGE/share/ai-gateway/"

install -m 644 var/ai-gateway/kernels/*.json "$STAGE/var/ai-gateway/kernels/" 2>/dev/null || true
install -m 755 var/ai-gateway/kernels/*.so   "$STAGE/var/ai-gateway/kernels/" 2>/dev/null || true

# --- self-check --------------------------------------------------------------
echo "-- self-check"
for b in spine-gateway vision-worker audio-worker ai-gateway; do
    [ -f "$STAGE/bin/$b" ] || die "missing $b"
done
if command -v file >/dev/null 2>&1; then
    for b in spine-gateway vision-worker audio-worker; do
        file "$STAGE/bin/$b" | grep -qi "RISC-V" || die "$b is not a riscv64 binary"
    done
fi
sh -n "$STAGE/bin/ai-gateway" || die "ai-gateway launcher has a syntax error"

echo "== ai-gateway build OK =="
