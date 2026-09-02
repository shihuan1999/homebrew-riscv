# openjiuwen-agent-tools — independent openJiuwen component package (OHOS riscv64).
# Upstream pin / port notes: see the riscv64-ohos branch of the
# corresponding fork under https://github.com/shihuan1999?tab=repositories
# Bottle layout: libexec/ tree + bin/ launcher (PYTHONPATH over the
# openjiuwen base closure; LD_PRELOAD libriscvflush; python3.12/3.11).
class OpenjiuwenAgentTools < Formula
  desc "openJiuwen agent-tools collection, source vendor pkg (OHOS riscv64)"
  homepage "https://github.com/openJiuwen-ai"
  url "https://github.com/openJiuwen-ai/agent-tools/archive/824a5170517104332d9358721286ce5178125794.tar.gz"
  sha256 "4cd8b02643fc173aa3a11d36fae1997b4efbfaa6a0fd7c8df3a0e266a0c6e229"
  version "1.0.0"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/openjiuwen-v2.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "d4a204589363d1cb19227de73b04c2d9a957a05023df4265eaa493299acc6246"
  end

  depends_on "hbrew/riscv/openjiuwen"

  def install
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      openjiuwen-agent-tools installed to #{prefix}. Port docs:
      see riscv64-ohos branch of the upstream fork on GitHub.
    EOS
  end

  test do
    system "true"
  end
end
