# riscv64_ohos prebuilt bottle — libsodium 1.0.20 (autotools cross, musl).
# Crypto backend for libzmq CURVE; shipped as a brew-native dependency of zeromq.
class Libsodium < Formula
  desc "Portable crypto library (musl riscv64) for zeromq CURVE"
  homepage "https://github.com/jedisct1/libsodium"
  url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles/libsodium-1.0.20-ohos-riscv64.tar.gz"
  sha256 "302a509546ccb536407ea6fc4d142081634fba35dfd091b04e18a2e5e9ca58df"
  version "1.0.20"
  license "ISC"

  bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "302a509546ccb536407ea6fc4d142081634fba35dfd091b04e18a2e5e9ca58df"
  end

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_predicate lib/"libsodium.so.26", :exist?
    assert_predicate include/"sodium/core.h", :exist?
  end
end
