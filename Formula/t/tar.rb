# riscv64_ohos prebuilt dist — ported from Harmonybrew/ohos-*, see build-org-tools.sh
class Tar < Formula
  desc "GNU tar archiver"
  homepage "https://www.gnu.org/software/tar/"
  url "https://mirrors.tuna.tsinghua.edu.cn/gnu/tar/tar-1.35.tar.gz"
  sha256 "14d55e32063ea9526e057fbf35fcabd53378e769787eff7919c3755b02d2b57e"
  version "1.35"


  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/bottles-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "e408763c475928f5255f5aaaa84e5785a7f4b8401ffb5158906fa992237639bf"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/tar-1.35-ohos-riscv64.tar.gz"
    sha256 "15d570f211e2f7eb20a0d9a6c2d22bfd671ce26f5bce834a853a221b1853dd7d"
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
