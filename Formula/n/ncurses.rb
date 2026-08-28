# riscv64_ohos prebuilt dist — ported from Harmonybrew/ohos-*, see build-org-tools.sh
class Ncurses < Formula
  desc "Text-based UI library (curses/terminfo)"
  homepage "https://www.gnu.org/software/ncurses/"
  url "https://mirrors.tuna.tsinghua.edu.cn/gnu/ncurses/ncurses-6.5.tar.gz"
  sha256 "136d91bc269a9a5785e5f9e980bc76ab57428f604ce3e5a5a90cebc767971cc6"
  version "6.5"


  bottle do
    root_url "http://10.0.50.17:8090/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "049224247c4a00001c6e66567a15da4a19c3f4340bbaec1aa95165adbf0d2722"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/ncurses-6.5-ohos-riscv64.tar.gz"
    sha256 "8989978eaabf6c10c81c28488f24dd3e6626c0bc6b17ebb269ac0cfd3e4bc71f"
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
