<!--
贡献方式二选一，详见 CONTRIBUTING.md：
  A. 源码贡献：formula（无需 bottle 块）+ builds/<name>/build.sh 配方
  B. 二进制贡献：formula 带 bottle 块（root_url 指向你的公网 release）
-->

- **包名 / 版本**：
- **贡献方式**：源码 / 二进制
- **上游**： <!-- 项目 homepage -->
- **设备自测**： <!-- `brew install` + `brew test` 的输出摘要（已自测请贴关键行） -->

## checklist

- [ ] formula 必填字段齐全（desc/homepage/url/sha256/version/license），类名与文件名一致
- [ ] `depends_on` 的依赖均已在 tap 中（或为 portable-ruby/portable-git）
- [ ] `test` 块真实执行了二进制（非 `system "true"` 空壳）
- [ ] （方式 A）`builds/<name>/build.sh` 只向 `$STAGE` 安装，用注入的 `$CC` 交叉编译
- [ ] （方式 B）bottle 命名 `<name>-<version>.riscv64_ohos.bottle.tar.gz`，keg 布局 `<name>/<version>/`，
      全部 ELF 为 riscv64 + musl/静态，sha256 与 formula 一致
- [ ] 所有 URL 公网可达（无 10.x/192.168.x/localhost）
