# riscv64_ohos bottle — built via builds/figlet/build.sh (see CONTRIBUTING.md)
# 贡献方式 A（源码贡献）：bottle 块由 publish 工作流在合并时自动补写。
class Figlet < Formula
  desc "Print large text banners in ASCII art from ordinary text"
  homepage "http://www.figlet.org/"
  url "https://deb.debian.org/debian/pool/main/f/figlet/figlet_2.2.5.orig.tar.gz"
  mirror "http://ftp.figlet.org/source/2.2.5/figlet-2.2.5.tar.gz"
  version "2.2.5"
  sha256 "bf88c40fd0f077dab2712f54f8d39ac952e4e9f2e1882f1195be9e5e4257417d"
  license "BSD-3-Clause"

  def install
    system "make", "figlet", "CC=#{ENV.cc}", "CFLAGS=#{ENV.cflags} -DDEFAULTFONTDIR=\\\"#{prefix}/share/figlet\\\" -DDEFAULTFONTFILE=\\\"standard.flf\\\""
    bin.install "figlet"
    (share/"figlet").install Dir["fonts/*.flf"]
    (share/"figlet").install Dir["fonts/*.flc"]
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/figlet -v 2>&1", 1)
    assert_match(/\S/, pipe_output("#{bin}/figlet -f standard", "hi"))
  end
end
