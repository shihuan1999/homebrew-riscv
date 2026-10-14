# riscv64_ohos bottle — built via builds/i2c-tools/build.sh (see CONTRIBUTING.md)
class I2cTools < Formula

      bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "35594360db86cba87d324ae6b6a93a81ffc0d14bc91ba5d0bbbda9f2ce08eaf9"
  end
  desc "I2C bus probing/transfer tools — sensors, servo controller boards"
  homepage "https://git.kernel.org/pub/scm/utils/i2c-tools/i2c-tools.git/"
  url "https://mirrors.edge.kernel.org/pub/software/utils/i2c-tools/i2c-tools-4.4.tar.xz"
  version "4.4"
  sha256 "8b15f0a880ab87280c40cfd7235cfff28134bf14d5646c07518b1ff6642a2473"
  license "LGPL-2.1-or-later"

  def install
    system "make", "CC=#{ENV.cc}", "EXTRA_CFLAGS=#{ENV.cflags}",
           "LDFLAGS=-Wl,-rpath,$ORIGIN/../lib", "PREFIX=#{prefix}", "all"
    system "make", "DESTDIR=#{File.dirname(prefix.to_s)}", "PREFIX=#{prefix}", "install"
  end

  def caveats
    <<~EOS
      Tools: i2cdetect / i2cdump / i2cget / i2cset / i2ctransfer
      K3 pico exposes /dev/i2c-1 /dev/i2c-2 /dev/i2c-5 /dev/i2c-6 /dev/i2c-9.
      i2c-dev must be loaded (modprobe i2c-dev) on the target.
    EOS
  end

  test do
    assert_match(/4\.4/, shell_output("#{sbin}/i2cdetect -V 2>&1"))
  end
end
