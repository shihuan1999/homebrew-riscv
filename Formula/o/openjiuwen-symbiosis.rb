# openjiuwen-symbiosis: robotics agent framework on openjiuwen (OHOS riscv64).
# Ships the pure-numpy scipy shim (scipy.spatial.transform Rotation/Slerp,
# numerically verified against scipy 1.17) in place of the unported Fortran/BLAS
# scipy. Mock acceptance: jiwensymbiosis-demo exits 0 with
# "mock: no real model, task skipped".
class OpenjiuwenSymbiosis < Formula
  desc "jiuwensymbiosis robotics agent framework + scipy shim (OHOS riscv64)"
  homepage "https://github.com/openJiuwen-ai/jiuwensymbiosis"
  url "https://github.com/openJiuwen-ai/jiuwensymbiosis/archive/ecc9283a9b2c3aa2223d257c194674e9fd3e06bf.tar.gz"
  sha256 "0d2a8afec86d6090b9652987ebec21917ab060f6e89d001c153225769fa576b0"
  version "0.1.0"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/openjiuwen-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "2a467bf4db96c6e0527057b49fe7265b4a7e73639799c162261d471dc2e2c4e6"
  end

  depends_on "hbrew/riscv/python"
  depends_on "hbrew/riscv/openjiuwen"

  def install
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      Mock acceptance demo (no robot / no LLM needed):
        jiwensymbiosis-demo
      Expected: Agent result contains "mock: no real model, task skipped", exit 0.
      Real-robot configs live in #{libexec}/configs; scipy is a numpy shim
      (spatial.transform only, verified vs scipy 1.17).
    EOS
  end

  test do
    system "#{bin}/jiwensymbiosis-demo"
  end
end
