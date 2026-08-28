# riscv64_ohos prebuilt dist — ported from Harmonybrew/ohos-*, see build-org-tools.sh
class M4 < Formula
  desc "GNU macro processor"
  homepage "https://www.gnu.org/software/m4/"
  url "https://mirrors.tuna.tsinghua.edu.cn/gnu/m4/m4-1.4.20.tar.gz"
  sha256 "6ac4fc31ce440debe63987c2ebbf9d7b6634e67a7c3279257dc7361de8bdb3ef"
  version "1.4.20"


  bottle do
    root_url "http://10.0.50.17:8090/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "2bf7c0c0941c1c63582abdcaf9db032e20a27037b020340e86235dc6242a9289"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/m4-1.4.20-ohos-riscv64.tar.gz"
    sha256 "874b4a1c439afe62a319cfd510f5346c3ed3a01725e7bd644cc1dd8897576c91"
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
