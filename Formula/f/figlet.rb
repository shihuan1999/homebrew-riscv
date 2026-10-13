# riscv64_ohos bottle — built via builds/figlet/build.sh (see CONTRIBUTING.md)
# 贡献方式 A（源码贡献）：bottle 块由 publish 工作流在合并时自动补写。
class Figlet < Formula

    bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "7d1cca9a17efb28fbd219bb12a9bad2a16e6d6c971b9218f7dff27a7862cecd8"
  end
  desc "Print large text banners in ASCII art from ordinary text"
  homepage "http://www.figlet.org/"
  url "https://deb.debian.org/debian/pool/main/f/figlet/figlet_2.2.5.orig.tar.gz"
  mirror "http://ftp.figlet.org/source/2.2.5/figlet-2.2.5.tar.gz"
  version "2.2.5"
  sha256 "bf88c40fd0f077dab2712f54f8d39ac952e4e9f2e1882f1195be9e5e4257417d"
  license "BSD-3-Clause"

  def install
    # 注意：Makefile 的 DEFAULTFONTFILE 默认不带后缀（figlet 自己会拼 .flf）；
    # DEFAULTFONTDIR 必须作为 make 变量传（Makefile 自带的 -D 会覆盖 CFLAGS 同名宏）
    system "make", "figlet", "CC=#{ENV.cc}", "DEFAULTFONTDIR=#{prefix}/share/figlet",
           "DEFAULTFONTFILE=standard",
           "CFLAGS=#{ENV.cflags} -std=gnu89 -D__BEGIN_DECLS= -D__END_DECLS="
    bin.install "figlet"
    (share/"figlet").install Dir["fonts/*.flf"]
    (share/"figlet").install Dir["fonts/*.flc"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/figlet -v 2>&1", 1)
    assert_match(/\S/, pipe_output("#{bin}/figlet -f standard", "hi"))
  end
end
