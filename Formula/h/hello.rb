# riscv64_ohos prebuilt dist — see harmonybrew-port/build-tools.sh
class Hello < Formula
  desc "GNU Hello, the classic hello world program"
  homepage "https://www.gnu.org/software/hello/"
  url "https://ftp.gnu.org/gnu/hello/hello-2.12.3.tar.gz"
  sha256 "0d5f60154382fee10b114a1c34e785d8b1f492073ae2d3a6f7b147687b366aa0"
  version "2.12.3"


  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/bottles-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "37a8c95ad8f8368d27703c88fcc83162bec7f6e1fa140067d5cd6dc55977e525"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/hello-2.12.3-ohos-riscv64.tar.gz"
    sha256 "cb2408aa0d950d4b4e71eab01414c9666a2e78427451cc45e589aba19f49c06a"
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
