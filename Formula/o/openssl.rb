# riscv64_ohos prebuilt dist — ported from Harmonybrew/ohos-*, see build-org-tools.sh
class Openssl < Formula
  desc "Cryptography and SSL/TLS toolkit"
  homepage "https://openssl.org/"
  url "https://github.com/openssl/openssl/releases/download/openssl-3.6.1/openssl-3.6.1.tar.gz"
  sha256 "b1bfedcd5b289ff22aee87c9d600f515767ebf45f77168cb6d64f231f518a82e"
  version "3.6.1"


  bottle do
    root_url "http://10.0.50.17:8090/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "47d28620a667126f35dc097fb732859540f70eca92af73d65e413bc501ffb66a"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/openssl-3.6.1-ohos-riscv64.tar.gz"
    sha256 "c16754ed9fdf29cc2788862de69a20d543beb57f3977ecbded01f15958b0c308"
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
