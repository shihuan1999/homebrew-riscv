# dsh (DeepSeek Harness) 0.1.0-rc.7 for OHOS riscv64.
# Upstream: npm @deepseek-ai/dsh. The bottle carries the full node_modules
# closure + cross-compiled native modules (node-pty, landlock, etc. — see
# shihuan1999/dsh-ohos-port patches/) + toolchain runtime libs; the node
# runtime itself comes from the separate node package (trapfix riscv64).
# Plugin management: `dsh plugin ...` forwards to pnpm — activate with
# `corepack enable && corepack prepare pnpm@latest --activate` (node pkg).
class Dsh < Formula
  desc "DeepSeek Harness (dsh): agentic coding harness (OHOS riscv64 port)"
  homepage "https://github.com/shihuan1999/dsh-ohos-port"
  url "https://registry.npmjs.org/@deepseek-ai/dsh/-/dsh-0.1.0-rc.7.tgz"
  sha256 "2f8f0b763d611ac536f7a9411ee43c0afc067c1b8732c3102c04dbe398bcacc5"
  version "0.1.0rc7"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/dsh-v0.1.0-rc.7-ohos"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "ade0d21760057170a64db06d1a008fd07632e30dbcd6083ecc7f72197ff8437a"
  end

  depends_on "hbrew/riscv/node"

  def install
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      dsh installed to #{prefix}. Quick start:
        dsh --version
        dsh --profile tui            # needs a working LLM endpoint
        DEEPSEEK_BASE_URL=http://<relay>:8000 dsh web
      Mock endpoint for offline testing: #{prefix}/bin/mock-llm.mjs
      Plugins (pnpm-backed):
        corepack enable && corepack prepare pnpm@latest --activate
        dsh plugin add <pkg>         # manages plugins in the profile dir
      State dir: $DSH_HOME (default #{prefix}/home); set
        export DSH_HOME=/data/dsh/home    # to reuse the pre-brew deployment
    EOS
  end

  test do
    system "#{bin}/dsh", "--version"
  end
end
