# riscv64_ohos prebuilt dist — ported from Harmonybrew/ohos-*, see build-org-tools.sh
class Patch < Formula
  desc "Apply a diff file to an original"
  homepage "https://www.gnu.org/software/patch/"
  url "https://mirrors.tuna.tsinghua.edu.cn/gnu/patch/patch-2.8.tar.gz"
  sha256 "308a4983ff324521b9b21310bfc2398ca861798f02307c79eb99bb0e0d2bf980"
  version "2.8"


  bottle do
    root_url "http://10.0.50.17:8090/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "5d23fa9460ef68d9cfad1c8f6e0682c8be73e4348ba2688c372e2c6de3f78086"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/patch-2.8-ohos-riscv64.tar.gz"
    sha256 "3ba2731afd88ab4c7358030811be02aad2e8efbec4c6a4993fe83482be26e9f0"
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
