# riscv64_ohos prebuilt dist — ported from Harmonybrew/ohos-*, see build-org-tools.sh
class Grep < Formula
  desc "GNU grep, print lines matching a pattern"
  homepage "https://www.gnu.org/software/grep/"
  url "https://mirrors.tuna.tsinghua.edu.cn/gnu/grep/grep-3.12.tar.gz"
  sha256 "badda546dfc4b9d97e992e2c35f3b5c7f20522ffcbe2f01ba1e9cdcbe7644cdc"
  version "3.12"


  bottle do
    root_url "http://10.0.50.17:8090/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "d50b6e6dfba9582d0af658001ba7ec76ae664f065bad3f40e4d18476981379cd"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/grep-3.12-ohos-riscv64.tar.gz"
    sha256 "303d62f117c921799457d1caf8ed5b76fe7924ddce710330e92f04ad7552a08d"
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
