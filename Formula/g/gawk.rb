# riscv64_ohos prebuilt dist — ported from Harmonybrew/ohos-*, see build-org-tools.sh
class Gawk < Formula
  desc "GNU awk pattern scanning language"
  homepage "https://www.gnu.org/software/gawk/"
  url "https://mirrors.tuna.tsinghua.edu.cn/gnu/gawk/gawk-5.3.2.tar.gz"
  sha256 "8639a1a88fb411a1be02663739d03e902a6d313b5c6fe024d0bfeb3341a19a11"
  version "5.3.2"


  bottle do
    root_url "http://10.0.50.17:8090/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "bd18e2d70a982253e3ac68c0c422da9b26d4c569e887814d4890da4e090602ca"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/gawk-5.3.2-ohos-riscv64.tar.gz"
    sha256 "bfb74b664ecc9cce8800f037b4d8729e6fb054c29a0c976fccbabdf07779e0ef"
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
