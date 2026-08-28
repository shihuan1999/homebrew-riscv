# riscv64_ohos prebuilt dist — ported from Harmonybrew/ohos-*, see build-org-tools.sh
class Zsh < Formula
  desc "Z shell, interactive shell and scripting language"
  homepage "https://www.zsh.org/"
  url "https://github.com/zsh-users/zsh/archive/refs/tags/zsh-5.9.tar.gz"
  sha256 "11ea641122396836441375f41f6cb2954890546857936b734ccad353ab62bf88"
  version "5.9"

  depends_on "ncurses"

  bottle do
    root_url "http://10.0.50.17:8090/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "19ae3d80e38ca593900179bd504cf739015f6a1c1299722835816033c67d1683"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/zsh-5.9-ohos-riscv64.tar.gz"
    sha256 "5bd81516aab5884cfebb9cbd67b8726c030379154d7e7a69091c3f875ee876c5"
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
