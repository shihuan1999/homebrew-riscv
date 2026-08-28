# riscv64_ohos prebuilt dist — see harmonybrew-port/build-tools.sh
class Tree < Formula
  desc "Display directories as trees"
  homepage "http://oldmanprogrammer.net/scode/tree.php"
  url "https://github.com/Old-Man-Programmer/tree/archive/refs/tags/2.1.1.tar.gz"
  sha256 "1b70253994dca48a59d6ed99390132f4d55c486bf0658468f8520e7e63666a06"
  version "2.1.1"


  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/bottles-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "7d621b7df49743724568cdd977ed373f61d7de3c45b179946d942c58fda072df"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/tree-2.1.1-ohos-riscv64.tar.gz"
    sha256 "add28ba47c0030d4a36827bdc641b379edb04282eb13a4a2b2d5e8d147bfbf1b"
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
