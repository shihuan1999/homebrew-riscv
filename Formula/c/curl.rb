# riscv64_ohos prebuilt dist — ported from Harmonybrew/ohos-*, see build-org-tools.sh
class Curl < Formula
  desc "Command line tool and library for URL transfers"
  homepage "https://curl.se/"
  url "https://github.com/curl/curl/releases/download/curl-8_19_0/curl-8.19.0.tar.gz"
  sha256 "2a2c11db4c122691aa23b4363befda1bfd801770bfebf41e1d21cee4f2ab0f71"
  version "8.19.0"

  depends_on "openssl"
  depends_on "zlib"

  bottle do
    root_url "http://10.0.50.17:8090/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "af3f87aab74ce8049bf3fcdad12b86d15594883622ed8ee362d1e3c165cc9814"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/curl-8.19.0-ohos-riscv64.tar.gz"
    sha256 "98f1a6e363ee9720e4e95bc4bd521f5fc387f7550fb2667f1a1b6e38f688250f"
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
