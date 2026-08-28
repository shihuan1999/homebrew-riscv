# riscv64_ohos prebuilt dist — ported from Harmonybrew/ohos-*, see build-org-tools.sh
class Zlib < Formula
  desc "General-purpose lossless data-compression library"
  homepage "https://zlib.net/"
  url "https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz"
  sha256 "9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23"
  version "1.3.1"


  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/bottles-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "3aa090f7a37b1fd956ce905c61f7d36c2ffc8e5aa63c09dc23d60ae39f3b634e"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/zlib-1.3.1-ohos-riscv64.tar.gz"
    sha256 "1de11a9cac21a97223c9e3ad9b3cd5f0a4d033dc709b2266d47cd4105196dd60"
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
