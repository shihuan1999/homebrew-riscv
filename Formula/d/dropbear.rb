# riscv64_ohos prebuilt dist — built natively on-device with clang-15 (see PORTING.md)
class Dropbear < Formula
  desc "Small SSH 2 server and client"
  homepage "https://matt.ucc.asn.au/dropbear/dropbear.html"
  url "https://dropbear.nl/mirror/releases/dropbear-2026.94.tar.gz"
  sha256 "5a7b61267f538b669cddb8ce3b98bd8e2482a7a06e95083414f9738ce3a8fe95"
  version "2026.94"

  bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "0da1eea23dad4d1fd73457cee11ecdd0ef485c5d33b3c1e804a311e8ee6fe793"
  end

  resource "ohos_riscv64_dist" do
    url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles/dropbear-2026.94-ohos-riscv64.tar.gz"
    sha256 "43c0cb8058229298d69b35a8f30d109fac5156d25760d43fa5baa6a4f0e8fbba"
  end

  def install
    resource("ohos_riscv64_dist").stage do
      prefix.install Dir["*"]
    end
  end

  test do
    system "#{bin}/ssh", "-V"
  end
end
