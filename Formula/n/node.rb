# Node.js v22.16.0 cross-built for OpenHarmony riscv64 (musl) with the
# spacemit LLVM toolchain. Two patches on top of upstream (SV39 address-hint
# mask fix in V8 + disable wasm trap handler); see
# https://github.com/shihuan1999/node/tree/riscv64-ohos for patches & docs.
# Verified on K3 pico (OHOS 6.1): runs dsh (DeepSeek Harness), npm install
# and corepack/pnpm on the device public network.
class Node < Formula
  desc "JavaScript runtime built on V8 (OpenHarmony riscv64 port)"
  homepage "https://nodejs.org/"
  url "https://nodejs.org/dist/v22.16.0/node-v22.16.0.tar.xz"
  sha256 "720894f323e5c1ac24968eb2676660c90730d715cb7f090be71a668662a17c37"
  version "22.16.0"
  license "MIT"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/node-v22.16.0-ohos"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "d1adf4a0b5a208cd52f6beddb35a52f6284da39cdba6feb3d5f84ed949b552da"
  end

  def install
    prefix.install Dir["*"]
    # keep shell wrappers functional regardless of prefix
    chmod 0755, bin/"node"
  end

  def caveats
    <<~EOS
      Node.js #{version} (OpenHarmony riscv64) installed to #{prefix}

      Patches / port docs: https://github.com/shihuan1999/node/tree/riscv64-ohos

      Enable pnpm for dsh plugin management:
        corepack enable && corepack prepare pnpm@latest --activate
    EOS
  end

  test do
    system "#{bin}/node", "-e", "puts(process.version)"
  end
end
