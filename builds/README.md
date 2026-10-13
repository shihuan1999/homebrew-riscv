# builds/ —— 源码构建配方

源码贡献方式（详见根目录 [CONTRIBUTING.md](../CONTRIBUTING.md)）中，每个包的
交叉编译逻辑放在 `builds/<name>/build.sh`，随 formula 一起通过 PR 提交。
PR 打上 `build-from-source` 标签后，snode7 上的 self-hosted runner 会执行
`contrib/build-from-source.sh`，它负责：

- 从 formula 解析 `url`/`sha256`/`version`，下载并校验源码
- 注入 spacemit musl riscv64 交叉工具链环境
- 在解压后的源码目录里执行你的 `build.sh`
- 把 `$STAGE` 目录打成 `<name>-<version>.riscv64_ohos.bottle.tar.gz`

## 配方约定

`build.sh` 运行环境：

| 变量 | 含义 |
|---|---|
| `STAGE` | 安装目标（keg 目录，形如 `<name>/<version>/`），**所有产物装到这** |
| `NAME` / `VERSION` | 包名与版本 |
| `HOST` | `riscv64-unknown-linux-musl` |
| `CC` `CXX` `AR` `RANLIB` `STRIP` | spacemit musl 工具链（gcc 14.2） |
| `CFLAGS` `CXXFLAGS` | `-O2 -pipe`（可追加） |
| `PREFIX` | 设备端 brew 前缀 `/data/harmonybrew`（baked 路径用） |
| `JOBS` | 并行度 |
| cwd | 已解压的源码目录顶层 |

要求：

1. 只往 `$STAGE` 写产物（bin/lib/share…），**不要**碰系统目录；
2. 二进制必须真的用 `$CC` 编出 riscv64（CI 会用 validate_bottle.py 校验 ELF）；
3. 返回码非 0 即视为构建失败；
4. 需要打补丁时把 `.patch` 文件放在同目录，配方里 `patch -p1 < ...`。

## 样例

- [figlet/build.sh](figlet/build.sh) —— autotools-less、Makefile 型小工具的典型配方。

## 本地/自托管环境试跑

```bash
contrib/build-from-source.sh figlet /tmp/out
```
