# openjiuwen-skillhub — independent openJiuwen component package (OHOS riscv64).
# Upstream pin / port notes: see the riscv64-ohos branch of the
# corresponding fork under https://github.com/shihuan1999?tab=repositories
# Bottle layout: libexec/ tree + bin/ launcher (PYTHONPATH over the
# openjiuwen base closure; LD_PRELOAD libriscvflush; python3.12/3.11).
class OpenjiuwenSkillhub < Formula
  desc "openJiuwen skillhub: skills marketplace + CLI, source vendor pkg (OHOS riscv64)"
  homepage "https://github.com/openJiuwen-ai"
  url "https://github.com/openJiuwen-ai/skillhub/archive/91a9e05d83a399a10088209fc44f0704c6904220.tar.gz"
  sha256 "e02ffac6eba066f9f7a478dd67500e9c535da73f4a2a684bcee6be9188436f63"
  version "1.0.0"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/openjiuwen-v2.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "51037202ce5b752f4012580d53f2beb79e407016c436a8dd67936afa0fea3448"
  end

  depends_on "hbrew/riscv/openjiuwen"

  def install
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      openjiuwen-skillhub installed to #{prefix}. Port docs:
      see riscv64-ohos branch of the upstream fork on GitHub.
    EOS
  end

  test do
    system "true"
  end
end
