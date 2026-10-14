# harmonybrew riscv64 musl wheel index

PEP 503 simple 索引，服务 OpenHarmony 6.1 / musl riscv64（SpacemiT K3 pico）
上的 CPython 3.12（`brew install hbrew/riscv/python`）。

- 索引地址（GitHub Pages）：`https://shihuan1999.github.io/homebrew-riscv/wheels/simple/`
- 轮子本体：本仓 release tag [`wheels`](https://github.com/shihuan1999/homebrew-riscv/releases/tag/wheels)
- 清单：[`manifest.json`](manifest.json)；生成索引页：`python3 contrib/make_wheel_index.py`
- 设备侧无需手工配置 —— python keg 的 `etc/pip.conf` 已把本索引列为第三源
  （`bin/python-env.sh` 会设置 `PIP_CONFIG_FILE`）。

## 标签约定

只收 `cp312-cp312-musllinux_1_2_riscv64`（以及未来的 cp31x / abi3 musllinux）。
`linux_riscv64` 通用标签**不收**：它对 musl 设备同样匹配，但无法与 glibc 构建
区分（gounthar/riscv64-python-wheels 的事故来源），统一用明确的 musllinux 标签。

## 红线

- 二进制必须真是 musl riscv64 交叉构建产物（`file` 显示 UCB RISC-V，
  ELF 解释器为 `ld-musl-riscv64.so.1` 或纯静态/无解释器的扩展 .so）
- 禁止把 glibc 二进制 retag 成 musllinux
- 上索引前必须在真机验证 import

贡献流程见 [CONTRIBUTING.md](../CONTRIBUTING.md) 方式 C；交叉构建后用
`contrib/retag_wheel.py` 重标记。
