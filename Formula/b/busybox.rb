# riscv64_ohos prebuilt dist — ported from Harmonybrew/ohos-*, see build-org-tools.sh
class Busybox < Formula
  desc "Swiss-army knife of embedded Linux"
  homepage "https://busybox.net/"
  url "https://busybox.net/downloads/busybox-1.37.0.tar.gz"
  sha256 "65643147a622ddf4689ade5f66a21f7cafb378ec595b4da3cd78c21412bf2230"
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
