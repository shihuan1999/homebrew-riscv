# riscv64_ohos prebuilt dist — see harmonybrew-port/build-tools.sh
class Nano < Formula
  desc "Free (GNU) replacement for Pico"
  homepage "https://www.nano-editor.org/"
  url "https://www.nano-editor.org/dist/v8/nano-8.5.tar.gz"
  sha256 "64538a1032ce02f11acce6603aa6a4c9d8f03f5f42504c2f7ee4aeed0cffe822"
  version "8.5"


  bottle do
    root_url "http://10.0.50.17:8090/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "3d49105e2ad4706a71e2c21cd4c5b0792ce92146b3322f72d6d4c492de6473ee"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/nano-8.5-ohos-riscv64.tar.gz"
    sha256 "108b6887373b892dfc7eb32c856557459d122e457f2bb7e13df7c107e7f89244"
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
