# homebrew-riscv (riscv64-ohos tap)

Bottles & formulas for **OpenHarmony 6.1 / musl riscv64** (SpacemiT K3 pico).
Binaries are cross-built (self-hosted runner on the compile server) and
verified on real hardware. New bottles are hosted on this repo's rolling
release ([`bottles`](https://github.com/shihuan1999/homebrew-riscv/releases/tag/bottles));
legacy bottles remain in
[shihuan1999/riscv-bin](https://github.com/shihuan1999/riscv-bin/releases).

## Contribute a package (two ways, full CI/CD)

See **[CONTRIBUTING.md](CONTRIBUTING.md)**. Short version:

```
源码贡献:  fork → brewkit new <name> <ver> → 写 Formula + builds/<name>/build.sh → PR
           → CI 校验 → 维护者打 build-from-source 标签 → snode7 runner 交叉编译出瓶
           → merge → publish 自动上瓶到中央 release + 规范化 formula + 重建快照/索引
二进制贡献: 设备上 brewpack pack <dir> → brewpack submit → bottle 上传你的 fork release
           → PR（CI 下载校验 riscv64/musl/结构/sha256）→ merge → publish 自动镜像
```

每个 PR 即时触发 CI；设备端验证见 `device-verify`（真机冒烟）。离线设备用
hdc 缓存预置安装（CONTRIBUTING.md「离线设备安装」）。

## Quick start (on device)

联网设备一键引导（brew 树 + portable-ruby + tap 全部来自本仓 `bootstrap-v1` release）：

```sh
. <(curl -fsSL https://raw.githubusercontent.com/shihuan1999/homebrew-riscv/main/contrib/install.sh)
brew install hbrew/riscv/<name>
```

```sh
# 2) install anything from this tap
brew install hbrew/riscv/<name>
```

## On-device AI inference — MindSpore Lite 2.4 (RVV-accelerated)

```sh
brew install hbrew/riscv/mindspore-lite   # runtime + benchmark + mslite-verify + ai-runner
brew install hbrew/riscv/mindspore-nnrt   # OH 6.1 NNRT client libs (needs NNRT service; K3 images ship none)
```

| Formula | What you get |
|---|---|
| `mindspore-lite` | MindSpore Lite 2.4 runtime for riscv64 (`-march=rv64gcv`), with a custom autovectorized 12x8 tile gemm patched into nnacl (~5x faster fp32 MatMul vs upstream reference): **10.7 GFLOP/s** matmul / **10.1 GFLOP/s** transformer block / **13.6 GB/s** gemv on the X100 cluster (8T), numerically verified vs onnxruntime (cosine = 1.0). A100 cluster (cpus 8-15) runs the same RVV kernels at lower throughput — use `ai-runner --affinity=8-15 -- <cmd>` for low-power background inference. gemv bandwidth (13.6 GB/s) is on par with or better than llama.cpp decode-phase (~10.6 GB/s, Qwen2.5-0.5B Q4_K_M 26.5 tok/s) on the same board. |
| `mindspore-nnrt` | `libneural_network_runtime.so` / `libneural_network_core.so` + proxy backends from the OH 6.1 tree. Stock K3 images have no NNRT system service (no NPU), so on K3 these are link-time components; the mslite NNRT delegate detects the missing backend and falls back to CPU cleanly. |

Post-install quick checks (also run by `brew test`):

```sh
mslite-verify $HBB_PREFIX/.../share/mindspore-lite/models/matmul_tg1.ms \
              .../matmul_tg1.input.bin .../matmul_tg1.output.bin    # cosine vs onnxruntime reference
benchmark --modelFile=.../block_qwen_w8.ms --loopCount=20 --numThreads=8
ai-runner --affinity=8-15 -- benchmark --modelFile=... --numThreads=8   # A100 cluster
```

Full benchmark model set (matmul pp128 / gemv / quantized transformer block,
ops sized like Qwen2.5-0.5B): release asset `bench-models-k3.tar.gz` on
[riscv-bin](https://github.com/shihuan1999/riscv-bin/releases/tag/bottles-v1.0).
Measured numbers and the comparison methodology live in the bottle's
`share/mindspore-lite/README.md`.

## openJiuwen agent suite — one command

Everything from the openJiuwen → OHOS riscv64 port, in one install:

```sh
brew install hbrew/riscv/openjiuwen-suite
```

| Formula | What you get |
|---|---|
| `openjiuwen` | agent-core 0.1.17 + full riscv64 python closure (pydantic-core / numpy / Pillow / pycryptodome / tiktoken … compiled; rest pure python) |
| `openjiuwen-apps` | on-device agent sidecar (:8765): deepsearch + local KB engine, career simulator, app-diag / perf agents, agent-memory, kbapp HAP source |
| `openjiuwen-symbiosis` | robotics agent framework incl. a pure-numpy `scipy.spatial.transform` shim (Rotation/Slerp, numerically verified vs scipy 1.17) |
| `openjiuwen-swarm` | jiuwenswarm AgentServer + E2A gateway, vendored agent-core develop tree, fastmcp/mcp/a2ui closure, psutil (abi3) |

Post-install quick checks:

```sh
openjiuwen                       # core import check
jiwensymbiosis-demo              # robotics mock acceptance (exit 0, no robot/LLM needed)
jiuwenswarm-init                 # create ~/.jiuwenswarm workspace, fill config/.env
jiuwenswarm-agentserver --port 18600 &
jiuwenswarm-smoke 18600          # one real LLM agent turn through the E2A websocket
openjiuwen-agents                # sidecar on :8765
```

Migration notes, pitfalls and the full story live in each formula header.

## Base toolchain

`python` (3.11.4, prebuilt), `portable-ruby`, `portable-git`, `xz`, `pigz`,
plus the classic unix tools (`bash`, `coreutils`, `curl`, `vim`, `zsh`,
`dropbear`, …). See `Formula/`.

## 2026-09-02 组件化发布（v2）

- **规范**：所有移植仓统一为「fork 保留原始代码 + `riscv64-ohos` 分支放补丁/说明」，
  总索引见 [OHOS-PORTS.md](OHOS-PORTS.md)。
- **新增独立组件包**（bottle 在 riscv-bin 对应 Release）：
  - `node` 22.16.0（SV39 掩码修复 + wasm trap-handler 补丁；dsh/vscode/dsh-plugin 的运行时）
  - `dsh` 0.1.0rc7（DeepSeek Harness，`dsh plugin`→pnpm 插件链）
  - `vscode-server` 1.109.5 + `code-hapdev` + `code-deveco`（hap-dev 与 deveco code 扩展安装器）
  - openJiuwen 独立组件：`openjiuwen-agent-memory` / `openjiuwen-deepsearch` /
    `openjiuwen-careersim` / `openjiuwen-agent-runtime` / `openjiuwen-agent-protocol` /
    `openjiuwen-agent-tools` / `openjiuwen-skillhub` / `openjiuwen-agent-dx`
    （聚合包 openjiuwen / openjiuwen-swarm / openjiuwen-symbiosis / openjiuwen-apps / openjiuwen-suite 保持不变）
- 应用侧 API 调用指南：[openjiuwen-ohos-port/docs/API.md](https://github.com/shihuan1999/openjiuwen-ohos-port/blob/main/docs/API.md)
