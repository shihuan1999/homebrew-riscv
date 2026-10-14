# riscv64_ohos bottle — built via builds/libgpiod/build.sh (see CONTRIBUTING.md)
# 贡献方式 A（源码贡献）：bottle 块由 publish 工作流在合并时自动补写。
class Libgpiod < Formula

      bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "1310e1b6714bc8a4578f689161a5cfdbdeb1caf0e0de447c89f4b5cbeac6c844"
  end
  desc "GPIO character device (/dev/gpiochip*) library and tools — robot IO control"
  homepage "https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/"
  url "https://mirrors.edge.kernel.org/pub/software/libs/libgpiod/libgpiod-2.3.1.tar.xz"
  version "2.3.1"
  sha256 "e3a358a90a9204ff16f92b6f4028ed91460b1926f10589eb54b3566484650a30"
  license "LGPL-2.1-or-later"

  def install
    # meson cross build, see builds/libgpiod/build.sh (K3 pico: /dev/gpiochip0-3)
    system "meson", "setup", "builddir", "--prefix=#{prefix}",
           "-Dtools=enabled", "-Dgpioset-interactive=disabled", "-Dtests=disabled",
           "-Dexamples=disabled", "-Dbindings-cxx=disabled", "-Dbindings-glib=disabled",
           "-Ddbus=disabled", "-Dintrospection=disabled", "-Dprofiling=false"
    system "ninja", "-C", "builddir"
    system "DESTDIR=#{File.dirname(prefix.to_s)}", "ninja", "-C", "builddir", "install"
  end

  def caveats
    <<~EOS
      Tools: gpiodetect / gpioinfo / gpioget / gpioset / gpiomon / gpionotify
      K3 pico exposes /dev/gpiochip0-3 (uAPI v2).
      GPIO needs appropriate vendor permissions on the device nodes.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gpiodetect --version 2>&1")
  end
end
