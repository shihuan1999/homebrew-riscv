# openjiuwen-agent-protocol — independent openJiuwen component package (OHOS riscv64).
# Upstream pin / port notes: see the riscv64-ohos branch of the
# corresponding fork under https://github.com/shihuan1999?tab=repositories
# Bottle layout: libexec/ tree + bin/ launcher (PYTHONPATH over the
# openjiuwen base closure; LD_PRELOAD libriscvflush; python3.12/3.11).
class OpenjiuwenAgentProtocol < Formula
  desc "openJiuwen Agent Protocol: A2A/MCP/AgentRegistry implementations, source vendor pkg (OHOS riscv64)"
  homepage "https://github.com/openJiuwen-ai"
  url "https://github.com/openJiuwen-ai/agent-protocol/archive/b25684052a7581723947474cb71f85c5f841e6a2.tar.gz"
  sha256 "7365ec5670a50324614a7645b747cbe648ae0a60a591bc96bf3c1a3897c26a17"
  version "1.0.0"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/openjiuwen-v2.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "3ec14e66bced79db13581c80e88c569121333e52ee22a892965dec0cd572a691"
  end

  depends_on "hbrew/riscv/openjiuwen"

  def install
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      openjiuwen-agent-protocol installed to #{prefix}. Port docs:
      see riscv64-ohos branch of the upstream fork on GitHub.
    EOS
  end

  test do
    system "true"
  end
end
