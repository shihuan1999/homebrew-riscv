# riscv64_ohos prebuilt dist — ported from Harmonybrew/ohos-*, see build-org-tools.sh
class Busybox < Formula
  desc "Swiss-army knife of embedded Linux"
  homepage "https://busybox.net/"
  url "http://deb.debian.org/debian/pool/main/b/busybox/busybox_1.37.0.orig.tar.bz2"
  sha256 "3311dff32e746499f4df0d5df04d7eb396382d7e108bb9250e7b519b837043a4"
  version "1.37.0"


  bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "265ab728e4aaf65cade7b8de294fc1fce83355463d9384c21f47bae49fe1f266"
  end

  resource "ohos_riscv64_dist" do
    url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles/busybox-1.37.0-ohos-riscv64.tar.gz"
    sha256 "d789e9a51d0bfb70022999e4e0a90b93b14fd6adec21f0cfde8270c67665c45a"
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
