# riscv64_ohos prebuilt dist — ported from Harmonybrew/ohos-*, see build-org-tools.sh
class Openssh < Formula
  desc "OpenBSD's SSH remote login client/server"
  homepage "https://www.openssh.com/"
  url "https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-10.4p1.tar.gz"
  sha256 "ef6026dd2aea8d56059638d5d3262902c892ceba9f88395835e0d06d3fb63238"
  version "10.4p1"

  depends_on "openssl"
  depends_on "zlib"

  bottle do
    root_url "http://10.0.50.17:8090/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "89b567b63326e57d9e919d3e1a331ee6bd26b0b883e3c186e8a3ec7a62cd390f"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/openssh-10.4p1-ohos-riscv64.tar.gz"
    sha256 "96085056a733791bad2e8b9cd7c5e4f8e24a7a3bda862970e98b022659e25b51"
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
