# riscv64_ohos prebuilt dist — ported from Harmonybrew/ohos-*, see build-org-tools.sh
class Diffutils < Formula
  desc "GNU diff, cmp, diff3 and sdiff"
  homepage "https://www.gnu.org/software/diffutils/"
  url "https://mirrors.tuna.tsinghua.edu.cn/gnu/diffutils/diffutils-3.12.tar.gz"
  sha256 "5be181b27ec38aad2450080661a64e4a1752bb29b7d5052bf0a02a70f623f9b2"
  version "3.12"


  bottle do
    root_url "http://10.0.50.17:8090/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "108f3f3ea67b624f1916fb962222abc15dfee9dc730780234cb7307a32e505cf"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/diffutils-3.12-ohos-riscv64.tar.gz"
    sha256 "3ca0754427907b480b86e7f3a5608bc3ff679fe1311fee4132016a5247de402c"
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
