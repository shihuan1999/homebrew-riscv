# riscv64_ohos bottle — built via builds/cjson/build.sh (see CONTRIBUTING.md)
class Cjson < Formula

      bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "6a96f9de6a5aa2fdf901517009d025ace601c4498abb2cbe216718d251548008"
  end
  desc "Ultralightweight JSON parser in ANSI C (mosquitto dependency)"
  homepage "https://github.com/DaveGamble/cJSON"
  url "https://github.com/DaveGamble/cJSON/archive/refs/tags/v1.7.18.tar.gz"
  version "1.7.18"
  sha256 "3aa806844a03442c00769b83e99970be70fbef03735ff898f4811dd03b9f5ee5"
  license "MIT"

  def install
    system "cmake", "-DCMAKE_C_COMPILER=#{ENV.cc}", "-DCMAKE_SYSTEM_NAME=Linux",
           "-DCMAKE_SYSTEM_PROCESSOR=riscv64", "-DCMAKE_INSTALL_PREFIX=#{prefix}",
           "-DENABLE_TESTING=OFF", "-DCMAKE_BUILD_TYPE=Release", "."
    system "make"
    system "make", "DESTDIR=#{File.dirname(prefix.to_s)}", "install"
  end

  test do
    assert File.exist?(lib/"libcjson.so.1")
  end
end
