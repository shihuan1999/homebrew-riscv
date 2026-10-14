# 贡献指南 —— 向 harmonybrew riscv64 tap 贡献包

面向 OpenHarmony（riscv64 musl，K3 pico / OH 6.1 实测基线）的 Homebrew 包生态。
任何人都可以贡献，支持三种方式：**源码贡献**（提交 formula + 交叉编译配方，
CI 帮你出瓶）、**二进制包贡献**（你自己构建 bottle，CI 校验后收录）和
**Python 轮子贡献**（musl riscv64 wheel，进本仓轮子索引）。
所有 PR 一经提交即刻触发 CI 校验，合并后自动发布到中央 bottle 托管。

```
贡献者                      GitHub CI/CD                         使用者
──────                    ──────────────                       ──────
formula + 配方/瓶 ──PR──▶ ci(校验) ─▶ build-source(编译*) ─▶ merge ─▶ publish(收编+快照) ─▶ 设备 brew install
                             │                                    │
                             └── device-verify(真机冒烟, 可选) ◀───┘
* 源码贡献方式；二进制贡献方式由 CI 直接下载并校验你的 bottle
```

## 仓库与角色

| 仓库 | 角色 |
|---|---|
| [shihuan1999/homebrew-riscv](https://github.com/shihuan1999/homebrew-riscv)（本仓库） | tap：`Formula/` 包定义、`builds/` 编译配方、`contrib/` 工具链；release tag `bottles` = 中央 bottle 托管；release tag `wheels` = musl riscv64 Python 轮子托管（PEP 503 索引见 GitHub Pages `wheels/simple/`） |
| [shihuan1999/riscv-bin](https://github.com/shihuan1999/riscv-bin) | 历史大件 bottle 归档（2026-09 之前的存量） |
| [Harmonybrew/ohos-*](https://github.com/orgs/Harmonybrew/repositories) | 上游组织（arm64）；riscv64 移植按 [OHOS-PORTS.md](OHOS-PORTS.md) 的 fork 规范回馈 |

## 准备

- 设备：K3 pico（OpenHarmony 6.1，API 23，riscv64 musl）。
  设备端装 brew：见 [contrib/install.sh](contrib/install.sh)（可联网）或下文"离线设备"。
- PC（可选）：git、python3、curl；便捷工具 `contrib/brewkit`。

## 方式 A：源码贡献（推荐，CI 代你交叉编译）

适合：会写构建脚本、希望生态可复现每个 bottle 的人。

1. fork 本仓库并克隆，生成骨架：
   ```bash
   contrib/brewkit new figlet 2.2.5 http://ftp.figlet.org/src/figlet-2.2.5.tar.gz
   ```
2. 补全 `Formula/f/figlet.rb`（desc/homepage/license/url/sha256/version、依赖、**真实 test**），
   并写好交叉编译配方 `builds/figlet/build.sh`（约定见 [builds/README.md](builds/README.md)：
   cwd=源码目录，产物全部装进 `$STAGE`，工具链用注入的 `$CC` 等）。
3. 本地预检（与 CI 同款）：
   ```bash
   contrib/brewkit check figlet
   ```
4. 提交 PR（`contrib/brewkit submit "add figlet 2.2.5"` 或网页方式）。
5. 维护者 review 配方后打 `build-from-source` 标签 → snode7 自托管 runner 用
   spacemit musl riscv64 工具链（gcc 14.2）执行配方出瓶，产物作为 artifact 附在 PR 上。
6. 合并 → `publish` 工作流自动：上传 bottle 到中央 release、把 formula 的 bottle 块
   规范化为中央地址、重建 `tap-latest.tar.gz` 与 `index.json`。

formula **不需要**自带 bottle 块——publish 会自动补写。

## 方式 B：二进制包贡献（bring-your-own-bottle）

适合：在设备上原生构建（brewpack）、或已有自己的交叉编译产物的人。

1. 产出规范 bottle（三种途径任选）：
   - **设备上直接打**（最简单）：用 [brewpack](https://github.com/shihuan1999/homebrew-riscv#设备端brewpack)
     `brewpack pack`，自动生成 bottle + formula；
   - PC 交叉编译后：`contrib/brewkit bottle <name> <version> <keg父目录>` 打包并自检；
   - 任何方式构建，满足下面的 bottle 规范即可。
2. 把 bottle 上传到一个**公网可达**的地址（推荐：你 fork 的 riscv-bin 或任意仓库的
   Release 资产），在 formula 中写明：
   ```ruby
   bottle do
     root_url "https://github.com/<你的用户名>/riscv-bin/releases/download/my-bottles"
     sha256 cellar: :any_skip_relocation, riscv64_ohos: "<bottle 的 sha256>"
   end
   ```
3. 提 PR。CI 会真实下载你的 bottle 并校验（见下），合并后 publish 自动把 bottle
   镜像到中央托管、改写 root_url —— 你的 fork release 之后可以删除。

## 方式 C：Python 轮子贡献（musl riscv64 wheel）

适合：为设备上的 CPython 3.12（`brew install hbrew/riscv/python`）补充
C 扩展轮子。设备 pip 的默认源见 README「Python multi-source pip policy」——
本仓轮子索引是唯一可控的 musl riscv64 轮子渠道，欢迎充实。

1. 在交叉编译机（musl riscv64 工具链 + 宿主 python3.12）上构建 wheel：
   ```bash
   # snode7 参考流程（完整脚本思路见 builds/python/build.sh 头部注释）
   export CC=riscv64-unknown-linux-musl-gcc
   export CFLAGS="-O2 -I<rootfs>/include/python3.12"
   export LDSHARED="$CC -shared"
   ~/py312host/bin/python3.12 setup.py bdist_wheel
   ```
2. 重标记：宿主产出的 wheel 名/扩展后缀是宿主平台的，用
   `contrib/retag_wheel.py` 一步修正（扩展改名 x86_64→riscv64、WHEEL Tag、
   RECORD 哈希重建、可选 strip）：
   ```bash
   python3 contrib/retag_wheel.py dist/pkg-1.0-cp312-cp312-linux_x86_64.whl \
       musllinux_1_2_riscv64 --strip <riscv64-strip>
   ```
3. 在真机验证 `pip install <wheel> && python -c "import pkg"`（retag 只修元数据，
   二进制本身的正确性你必须自己验）。
4. 提 PR：
   - wheel 文件先上传到你 fork 的任意 release，PR 里附直链 + sha256 + 真机验证截图/日志；
   - 同时在 `wheels/manifest.json` 追加条目（name/version/tag/url/sha256/origin），
     并运行 `python3 contrib/make_wheel_index.py` 重新生成索引页；
   - 维护者验证后把 wheel 收编到本仓 `wheels` release 并改写 url。
5. **红线**：只收 musl 构建的轮子。禁止把 glibc 二进制 retag 成 musllinux（装得上、
   import 即炸，且污染标签信誉）；禁止提交宿主 x86_64 轮子充当 riscv64。

## bottle 规范（CI 强制）

- 文件名：`<name>-<version>.riscv64_ohos.bottle.tar.gz`（单横线，brew fork 的推导规则）
- 内部布局：keg 形式，顶层必须且只有 `<name>/<version>/`；
  版本化 formula（如 `python@3.11`）顶层目录用同名 `python@3.11/3.11.4/`，
  类名按 Homebrew 规则 `@`→`AT` 且去掉点（`PythonAT311`）
- 架构：bin/sbin/libexec/lib 下所有 ELF 必须是 **riscv64**，动态链接的解释器必须是
  `ld-musl-riscv64.so.1`（或静态）；**不得**出现 glibc 特征（libc.so.6 等）
- 安全：无绝对路径 / `..` / 越出 keg 的符号链接 / 设备文件 / setuid 位
- sha256 与 formula `bottle do` 块一致；体积 ≤ 400MB
- formula：类名与文件名一致、desc/homepage/url/sha256/version 齐全、
  `depends_on` 的包必须在 tap 内存在、`test` 块必须真实执行二进制（空壳 `system "true"` 会警告）
- **禁止内网 URL**：任何 url/root_url 指向 10.x/127.x/192.168.x 等私网地址直接 FAIL
  （第三方不可达）

## CI/CD 说明

| 工作流 | 触发 | 干什么 |
|---|---|---|
| `ci` | 每个 PR / push main | formula 静态校验 + bottle 下载校验；push main 额外做全量 URL 健康检查 |
| `build-source` | PR 标签 `build-from-source`（仅维护者可打）| snode7 自托管 runner 交叉编译出瓶 + artifact |
| `device-verify` | PR 标签 `device-verify` / 手动 | 网关 runner 通过 hdc 在真机安装 + `brew test` 冒烟 |
| `publish` | PR 合并 / 手动 | 收编 bottle 到中央 release、规范化 formula、重建快照与索引 |

安全约定：`builds/*.sh` 会在自托管 runner 上真实执行，因此**只有 review 通过后维护者
才会打 `build-from-source` 标签**；首次贡献者的 PR 需维护者批准才会跑 CI（GitHub 默认策略）。

## 离线设备安装（hdc 预置缓存）

设备无法访问 GitHub 时，在 PC 侧：

```bash
# 1. 取 bottle（中央 release）
curl -fLO https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles/<name>-<ver>.riscv64_ohos.bottle.tar.gz
# 2. 计算 brew 缓存名并推送（URL 哈希--文件名）
python3 -c "import hashlib,sys;print(hashlib.sha256(b'<bottle 完整 URL>').hexdigest()+'--<文件名>')"
hdc file send <文件> /data/hbrew-home/.cache/Homebrew/<上面算出的名字>
# 3. 设备上安装
hdc shell ". /data/harmonybrew/hbrew-env.sh && brew install hbrew/riscv/<name>"
```

## 反馈

- 问题/请求新包：开 Issue；
- riscv64 移植经验（fork 规范、补丁、版本升级流程）：见 [OHOS-PORTS.md](OHOS-PORTS.md)。

## 许可

提交到本仓库的 formula/配方以 BSD-2-Clause 授权（与上游 Harmonybrew 组织一致），
见 [LICENSE](LICENSE)。
