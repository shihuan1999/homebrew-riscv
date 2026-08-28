# riscv64_ohos prebuilt dist — ported from Harmonybrew/ohos-*, see build-org-tools.sh
class Vim < Formula
  desc "Vi 'workalike' with many additional features"
  homepage "https://www.vim.org/"
  url "https://github.com/vim/vim/archive/refs/tags/v9.2.0150.tar.gz"
  sha256 "bd56f5981eb4cb971eaf58725bf590f4b4c067b911b8e70dcd813b7de2392197"
  version "9.2.0150"

  depends_on "ncurses"

  bottle do
    root_url "http://10.0.50.17:8090/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "d9ff6fd27ea4e2ff5fd03b315e40afbd327848fe533f86df11cd055e50a6dd80"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/vim-9.2.0150-ohos-riscv64.tar.gz"
    sha256 "faec62ed2be10cc75c65572bc39b82a33e88cd4b6bd81ed8a0c15724407ab5cd"
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
