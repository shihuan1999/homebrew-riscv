# riscv64_ohos prebuilt dist — ported from Harmonybrew/ohos-*, see build-org-tools.sh
class Busybox < Formula
  desc "Swiss-army knife of embedded Linux"
  homepage "https://busybox.net/"
  url "http://deb.debian.org/debian/pool/main/b/busybox/busybox_1.37.0.orig.tar.bz2"
  sha256 "3311dff32e746499f4df0d5df04d7eb396382d7e108bb9250e7b519b837043a4"
  version "1.37.0"


  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/bottles-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "f2dc7be248825f91d849330a975fcaca4b1c82f69673411cb1b94606448a7940"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/busybox-1.37.0-ohos-riscv64.tar.gz"
    sha256 "86a8bb6c500191636e9dfed996ab8a4e4a23493c263d4afcc651e7aa6ee63753"
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
