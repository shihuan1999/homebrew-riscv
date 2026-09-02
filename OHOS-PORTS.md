# OHOS riscv64 移植仓规范与索引（OHOS-PORTS）

本文件是所有 OpenHarmony riscv64 移植仓的**统一存放规范**与**总索引**。
目标：每个移植项目都以「**原始代码仓（fork） + riscv 适配补丁 + 说明**」的形式存放在 GitHub 上，
上游发版后只需重放补丁即可跟进，不用维护一份脱离上游的完整源码副本。

## 一、仓库结构规范

每个移植项目对应一个 GitHub fork 仓（fork 自上游原始仓，保留 fork 关系与上游默认分支原样）：

```
shihuan1999/<repo>          # fork 本体：默认分支 = 上游原始代码，绝不相fork上写乱
└── 分支 riscv64-ohos       # 孤儿分支：只放移植适配层，不包含上游源码
    ├── README.md           # 移植说明（基线版本/补丁表/构建/部署/坑/验证记录）
    ├── patches/*.patch     # 相对上游 tag 的源码补丁（patch -p1 / git apply）
    ├── build.sh            # 编译服务器(snode7)一键交叉构建脚本
    └── ohos-deploy/        # （可选）设备端部署脚本/launcher/overlay
```

规则：

1. **原始代码保留**：fork 的默认分支跟随上游（Sync fork 即可更新），不 push 任何改动；
2. **适配全部走补丁**：`patches/` 内补丁按序号排序，每个补丁头部注释写明动机与现象；
3. **说明必须可复现**：README 写清 上游基线 tag/commit、工具链、configure/make 参数、
   部署方式（brew 或手工）、设备验证记录（哪台板、哪个系统版本、跑了什么）；
4. **非源码类适配**（launcher、依赖闭包、shim）放 `ohos-deploy/`，不伪造源码补丁；
5. **版本更新流程**：同步 fork → 切新 tag → 重放 patches → 冲突手工修 → 重跑 build.sh →
   设备冒烟 → 更新 README 基线信息 → 重发 bottle。

## 二、brew 包约定

- Tap：`shihuan1999/homebrew-riscv`（设备端 `hbrew/riscv/<name>`）
- Bottle：`<name>-<version>.riscv64_ohos.bottle.tar.gz`，内部为 `<name>/<version>/` 前缀树，
  发布在 `shihuan1999/riscv-bin` 的对应 Release（一个组件一个 tag）；
- Formula 的 `bottle.root_url` 指向对应 Release；源码 `url` 指向上游官方发布物（补丁信息写入注释）。

## 三、移植仓总索引

### 基础工具链（Harmonybrew/ohos-* fork 系列）

| 组件 | 上游 | fork | riscv64-ohos 分支 | brew 包 |
|---|---|---|---|---|
| bash 5.3 | Harmonybrew/ohos-bash | shihuan1999/ohos-bash | ✔ | bash |
| busybox 1.37 | Harmonybrew/ohos-busybox | shihuan1999/ohos-busybox | ✔ | busybox |
| coreutils 9.11 | GNU | shihuan1999/ohos-coreutils | ✔ | coreutils |
| curl 8.19 | curl/curl | shihuan1999/ohos-curl | ✔ | curl |
| git 2.55 | Git SCM | shihuan1999/ohos-git | ✔ | portable-git |
| vim / zsh / jq / less / nano / tree / make / … | 各上游 | shihuan1999/ohos-* | ✔ | 同名 |
| python 3.11.4 | python/cpython | shihuan1999/ohos-python | ✔ | python |
| dropbear | mkj/dropbear | —（自移植） | — | dropbear |
| node 22.16.0 | nodejs/node | shihuan1999/node | ✔ | node |

### openJiuwen 全家桶（openJiuwen-ai fork 系列）

| 组件 | 上游基线 | fork | brew 包（独立组件） |
|---|---|---|---|
| openJiuwen 框架（agent-core） | develop@1889660 | shihuan1999/agent-core | openjiuwen（基础闭包） |
| jiuwenswarm | develop@7859993 | shihuan1999/jiuwenswarm | openjiuwen-swarm |
| jiuwensymbiosis | main@ecc9283 | shihuan1999/jiuwensymbiosis | openjiuwen-symbiosis |
| agent-memory | develop | shihuan1999/agent-memory | openjiuwen-agent-memory |
| deepsearch | main | shihuan1999/deepsearch | openjiuwen-deepsearch |
| CareerSim-BDCI26 | main | shihuan1999/CareerSim-BDCI26 | openjiuwen-careersim |
| agent-runtime | main@34ed6e8 | shihuan1999/agent-runtime | openjiuwen-agent-runtime |
| agent-protocol | main@b256840 | shihuan1999/agent-protocol | openjiuwen-agent-protocol |
| agent-tools | dev@824a517 | shihuan1999/agent-tools | openjiuwen-agent-tools |
| skillhub | develop@91a9e05 | shihuan1999/skillhub | openjiuwen-skillhub |
| agent-dx | master | shihuan1999/agent-dx | openjiuwen-agent-dx |
| sciencediscovery / relay / agent-studio / docs / community | — | 已 fork | 评估文档见各自 riscv64-ohos 分支 |
| agent-core-java / agent-runtime-java | — | 未移植 | 需 JDK17+ riscv64（暂缺） |

### 开发工具链

| 组件 | 上游 | fork/仓 | brew 包 |
|---|---|---|---|
| openvscode-server | gitpod-io/openvscode-server | shihuan1999/openvscode-server | vscode-server |
| vscode 插件 ohos-dev（hap-dev） | 自研 | shihuan1999/vscode-ohos-port | code-hapdev |
| vscode 插件 deveco-code | 自研 | shihuan1999/deveco-ohos-port | code-deveco |
| dsh（DeepSeek Harness） | npm @deepseek-ai/dsh | shihuan1999/dsh-ohos-port | dsh |
| hap-dev（设备端 HAP 工具链） | 自研 | shihuan1999/ondevice-hap-dev | hap-dev |
| llama.cpp | ggml-org/llama.cpp | shihuan1999/llamacpp-ohos-port | — |

## 四、应用调用 openJiuwen 接口

所有组件在设备上以本地服务形式暴露 HTTP/WS 接口，任何 HAP/前端/脚本均可调用：
AgentServer（WS :18600）、agents sidecar（HTTP :8765）、memory_server（HTTP :8000）、
kb_agent / kb 检索等。接口契约与示例见
[openjiuwen-ohos-port/docs/API.md](https://github.com/shihuan1999/openjiuwen-ohos-port/blob/main/docs/API.md)。
