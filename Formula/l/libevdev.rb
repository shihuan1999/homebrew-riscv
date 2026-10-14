# riscv64_ohos bottle — built via builds/libevdev/build.sh (see CONTRIBUTING.md)
class Libevdev < Formula

      bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "5f4a197273a83d2ddd1ca11db783519bec6d26564b6c0fce6d1fa57ede5d35bf"
  end
  desc "Wrapper for /dev/input event codes — gamepads and remote teleop"
  homepage "https://www.freedesktop.org/wiki/Software/libevdev/"
  url "https://www.freedesktop.org/software/libevdev/libevdev-1.13.4.tar.xz"
  version "1.13.4"
  sha256 "f00ab8d42ad8b905296fab67e13b871f1a424839331516642100f82ad88127cd"
  license "MIT"

  def install
    system "./configure", "--host=#{ENV["HOST"] || "riscv64-unknown-linux-musl"}",
           "--prefix=#{prefix}", "--disable-tests", "--disable-documentation"
    system "make"
    system "make", "DESTDIR=#{File.dirname(prefix.to_s)}", "install"
  end

  def caveats
    <<~EOS
      K3 pico exposes /dev/input/event0-event1.
      Pair with Python evdev or C consumers for gamepad-driven teleop.
    EOS
  end

  test do
    assert File.exist?(lib/"libevdev.so.2")
  end
end
