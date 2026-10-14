# riscv64_ohos bottle — built via builds/libserialport/build.sh (see CONTRIBUTING.md)
class Libserialport < Formula

      bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "576a648a7f7bc0e346f7701316897b6eb4cdc06fe5d493b193940e6578f05960"
  end
  desc "Cross-platform serial port access library — bus servos, lidar, GPS"
  homepage "https://sigrok.org/wiki/Libserialport"
  url "https://github.com/sigrokproject/libserialport/archive/refs/tags/libserialport-0.1.2.tar.gz"
  version "0.1.2"
  sha256 "cbb1192a09ff31d34e7efdb17a2f50d9d1974461c0b81c29bb449515d78d8950"
  license "LGPL-3.0-or-later"

  def install
    # K3 pico UARTs: /dev/ttyS0..ttyS15
    system "./configure", "--host=#{ENV["HOST"] || "riscv64-unknown-linux-musl"}",
           "--prefix=#{prefix}", "--disable-examples"
    system "make"
    system "make", "DESTDIR=#{File.dirname(prefix.to_s)}", "install"
  end

  test do
    assert File.exist?(lib/"libserialport.so")
  end
end
