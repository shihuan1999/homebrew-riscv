# openjiuwen-careersim — independent openJiuwen component package (OHOS riscv64).
# Upstream pin / port notes: see the riscv64-ohos branch of the
# corresponding fork under https://github.com/shihuan1999?tab=repositories
# Bottle layout: libexec/ tree + bin/ launcher (PYTHONPATH over the
# openjiuwen base closure; LD_PRELOAD libriscvflush; python3.12/3.11).
class OpenjiuwenCareersim < Formula
  desc "openJiuwen CareerSim (CCF BDCI 2026) headless career simulation runner (OHOS riscv64)"
  homepage "https://github.com/openJiuwen-ai"
  url "https://github.com/openJiuwen-ai/CareerSim-BDCI26/archive/f61c738c72e51b77298cc1c14c7c6ebf4b6c527d.tar.gz"
  sha256 "b7b069fd5ba82bd20e75466ca2504c5d396ab7a51f856e81e2cfd7d29afed0fd"
  version "1.0.0"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/openjiuwen-v2.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "f91dfd88ec26edfc6346841e20f9025ec8aa0bf4bdfada38c282b00321d0169f"
  end

  depends_on "hbrew/riscv/openjiuwen"

  def install
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      openjiuwen-careersim installed to #{prefix}. Port docs:
      see riscv64-ohos branch of the upstream fork on GitHub.
    EOS
  end

  test do
    system "true"
  end
end
