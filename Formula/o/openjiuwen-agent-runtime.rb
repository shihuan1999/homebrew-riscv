# openjiuwen-agent-runtime — independent openJiuwen component package (OHOS riscv64).
# Upstream pin / port notes: see the riscv64-ohos branch of the
# corresponding fork under https://github.com/shihuan1999?tab=repositories
# Bottle layout: libexec/ tree + bin/ launcher (PYTHONPATH over the
# openjiuwen base closure; LD_PRELOAD libriscvflush; python3.12/3.11).
class OpenjiuwenAgentRuntime < Formula
  desc "openJiuwen Agent Runtime: agent run/deploy framework, source vendor pkg (OHOS riscv64)"
  homepage "https://github.com/openJiuwen-ai"
  url "https://github.com/openJiuwen-ai/agent-runtime/archive/34ed6e86b99fab9b3f07d9f063efc1692ab365d2.tar.gz"
  sha256 "79277fb80beb9897288cf338b8c881d4cf97ec02e00b2d6bcf3dc4a60c15158e"
  version "1.0.0"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/openjiuwen-v2.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "2e31f9d889345cc6c255fed711d2bc397dc582e14a613ae59729b24346c3799f"
  end

  depends_on "hbrew/riscv/openjiuwen"

  def install
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      openjiuwen-agent-runtime installed to #{prefix}. Port docs:
      see riscv64-ohos branch of the upstream fork on GitHub.
    EOS
  end

  test do
    system "true"
  end
end
