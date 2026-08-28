# riscv64_ohos prebuilt dist — see harmonybrew-port/build-tools.sh
class Jq < Formula
  desc "Lightweight and flexible command-line JSON processor"
  homepage "https://jqlang.github.io/jq/"
  url "https://github.com/jqlang/jq/releases/download/jq-1.8.1/jq-1.8.1.tar.gz"
  sha256 "2be64e7129cecb11d5906290eba10af694fb9e3e7f9fc208a311dc33ca837eb0"
  version "1.8.1"


  bottle do
    root_url "http://10.0.50.17:8090/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "67c766b350cd1c584a231fb27c1dd9e57d8d460d8391861ed1fb606a5555cc3a"
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
