# riscv64_ohos prebuilt dist — ported from Harmonybrew/ohos-*, see build-org-tools.sh
class Sed < Formula
  desc "GNU stream editor"
  homepage "https://www.gnu.org/software/sed/"
  url "https://mirrors.tuna.tsinghua.edu.cn/gnu/sed/sed-4.10.tar.gz"
  sha256 "4d179ffaf92ec4dcec541f7c032be1c3b9a1856f4970adb95a505221702f5277"
  version "4.10"


  bottle do
    root_url "http://10.0.50.17:8090/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "4326961691fb75e837f7f8c8ad4926f733c3aefeb45c79cc44aba4cdeec5854d"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/sed-4.10-ohos-riscv64.tar.gz"
    sha256 "6b1c7240875acec600b8ee789b417edb2274a0c13854572a621663f2d2f6e433"
  end

  def install
    resource("ohos_riscv64_dist").stage do
      prefix.install Dir["*"]
    end
  end

  test do
    system "true"
  end
end
