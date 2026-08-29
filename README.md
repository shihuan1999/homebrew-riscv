# homebrew-riscv (riscv64-ohos tap)

Bottles & formulas for **OpenHarmony 6.1 / musl riscv64** (SpacemiT K3 pico).
All binaries are cross-built on the compile server and verified on real
hardware. Bottles are hosted in
[shihuan1999/riscv-bin](https://github.com/shihuan1999/riscv-bin/releases).

## Quick start (on device)

```sh
# 1) load the harmonybrew environment (see repo root README for bootstrap)
. /data/hbrew-pkgs/hbrew-shell

# 2) install anything from this tap
brew install hbrew/riscv/<name>
```

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
