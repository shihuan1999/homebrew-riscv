# riscv64_ohos prebuilt dist — see harmonybrew-port/build-tools.sh
class Jq < Formula
  desc "Lightweight and flexible command-line JSON processor"
  homepage "https://jqlang.github.io/jq/"
  url "https://github.com/jqlang/jq/releases/download/jq-1.8.1/jq-1.8.1.tar.gz"
  sha256 "2be64e7129cecb11d5906290eba10af694fb9e3e7f9fc208a311dc33ca837eb0"
  version "1.8.1"


  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/bottles-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "529d1658699071093b8b3f86d59e1712a7a00ab208ae0d9869b8f0237b9c3866"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/jq-1.8.1-ohos-riscv64.tar.gz"
    sha256 "911a39055c7dfedb0cdd272a60828a37003fd64f2832253023fe6d4b1f7020b4"
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
