# openjiuwen-agent-memory — independent openJiuwen component package (OHOS riscv64).
# Upstream pin / port notes: see the riscv64-ohos branch of the
# corresponding fork under https://github.com/shihuan1999?tab=repositories
# Bottle layout: libexec/ tree + bin/ launcher (PYTHONPATH over the
# openjiuwen base closure; LD_PRELOAD libriscvflush; python3.12/3.11).
class OpenjiuwenAgentMemory < Formula
  desc "openJiuwen agent-memory: long-term memory server (hash embedding + SQLite vector store) for OHOS riscv64"
  homepage "https://github.com/openJiuwen-ai"
  url "https://github.com/openJiuwen-ai/agent-memory/archive/9bf45fa4154fc448cbe6a126958c50b9f26a1685.tar.gz"
  sha256 "050d7387e4f538122d7e35d469a5a8737ead561e45637e6a71a5ff61b124ea36"
  version "1.0.0"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/openjiuwen-v2.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "54f1113a40ae094e9b1d37332693c325f7dbf30d9e524891176b4917cdce0368"
  end

  depends_on "hbrew/riscv/openjiuwen"

  def install
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      openjiuwen-agent-memory installed to #{prefix}. Port docs:
      see riscv64-ohos branch of the upstream fork on GitHub.
    EOS
  end

  test do
    system "true"
  end
end
