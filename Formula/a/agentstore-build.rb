# agentstore-build — hvigor 6.24.2 build chain (pure-JS) + launcher for OHOS HAP
# projects. Lets an OHOS riscv64 device (or any host with node) build HAPs without
# a DevEco install. The hvigor-ohos-plugin vendored optional native accelerators
# (oxc-resolver *.node) are stripped — non-riscv64 ELF violates the tap policy and
# the pure-JS path is what hvigor uses at build time.
class AgentstoreBuild < Formula
  desc "hvigor 6.24.2 build chain + agentstore-build launcher for HAP projects (pure-JS, riscv64-clean)"
  homepage "https://github.com/spacemit-com"
  url "https://github.com/shihuan1999/riscv-bin/raw/agentstore-v1.0/agentstore-v1.0/agentstore-build-1.0.0.riscv64_ohos.bottle.tar.gz"
  sha256 "09ea7471e5bb6aad396031a001c6d26df92f251902cc72c6fd7bba3770663b6e"
  version "1.0.0"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "09ea7471e5bb6aad396031a001c6d26df92f251902cc72c6fd7bba3770663b6e"
  end

  depends_on "hbrew/riscv/node"

  def install
    prefix.install Dir["*"]
    # 恢复插件对 hvigor core 的模块链接（bottle 打包时剔除以避免实体双份）
    ohosdir = libexec/"hvigor/hvigor-ohos-plugin/node_modules/@ohos"
    ohosdir.mkpath
    ln_sf (libexec/"hvigor/hvigor"), ohosdir/"hvigor"
  end

  def caveats
    <<~EOS
      Build a HAP project (device or any host with node):
        agentstore-build /path/to/hap-project          # = assembleHap
        agentstore-build /path/to/project ...args      # passthrough hvigor args

      Requirements:
        - node on PATH (brew install hbrew/riscv/node, or AGENTSTORE_BUILD_NODE=...)
        - OHOS SDK components laid out as <sdk.dir>/<api>/{ets,js,native,previewer,toolchains}
          and project local.properties sdk.dir pointing at the SDK parent
          (PC: D:/openharmonysdk; device: extract oh-sdk-23-riscv64 tarball)

      The launcher auto-creates project node_modules/@ohos/{hvigor,hvigor-ohos-plugin}
      links into this Cellar (mirrors the DevEco per-project hvigor layout).
    EOS
  end

  test do
    assert (prefix/"libexec/hvigor/hvigor/bin/hvigor.js").exist?
    assert (prefix/"libexec/hvigor/hvigor-ohos-plugin/node_modules/@ohos/hvigor").exist?
  end
end
