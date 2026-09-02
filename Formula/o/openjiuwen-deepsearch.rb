# openjiuwen-deepsearch — independent openJiuwen component package (OHOS riscv64).
# Upstream pin / port notes: see the riscv64-ohos branch of the
# corresponding fork under https://github.com/shihuan1999?tab=repositories
# Bottle layout: libexec/ tree + bin/ launcher (PYTHONPATH over the
# openjiuwen base closure; LD_PRELOAD libriscvflush; python3.12/3.11).
class OpenjiuwenDeepsearch < Formula
  desc "openJiuwen DeepSearch knowledge-enhanced deep research agent (OHOS riscv64)"
  homepage "https://github.com/openJiuwen-ai"
  url "https://github.com/openJiuwen-ai/deepsearch/archive/62aa0e3718d83806aa42c4d89dfe33c2c3a11db0.tar.gz"
  sha256 "427f93f8f64001e89f7fd92db40d943c4c2adaf074299cb5430ae36a50d5ff81"
  version "1.0.0"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/openjiuwen-v2.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "aa4503037b0c22c758a4b00d94da90fa741f8515f31321c485c98119416ccf81"
  end

  depends_on "hbrew/riscv/openjiuwen"

  def install
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      openjiuwen-deepsearch installed to #{prefix}. Port docs:
      see riscv64-ohos branch of the upstream fork on GitHub.
    EOS
  end

  test do
    system "true"
  end
end
