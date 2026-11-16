# riscv64_ohos prebuilt bottle — libzmq 4.3.5 (cmake cross, WITH_LIBBSD=OFF since
# musl has strlcpy; CURVE via bundled libsodium). Used by ros2_spacemit humanoid HMI.
class Zeromq < Formula
  desc "ZeroMQ core messaging library (musl riscv64) for spacemit humanoid"
  homepage "https://github.com/zeromq/libzmq"
  url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles/zeromq-4.3.5-ohos-riscv64.tar.gz"
  sha256 "63e21a8068a1cb3285b93a90de6b84c95e0c0b368a25763a863fc3f7c928107f"
  version "4.3.5"
  license "MPL-2.0"

  depends_on "libsodium"

  bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "63e21a8068a1cb3285b93a90de6b84c95e0c0b368a25763a863fc3f7c928107f"
  end

  def install
    prefix.install Dir["*"]
  end

  def post_install
    # libzmq.so.5 NEEDEDs libsodium.so.26 — resolved via LD_LIBRARY_PATH chain
    (bin/"zeromq-env").write <<~EOS
      #!/bin/sh
      export LD_LIBRARY_PATH=#{opt_lib}:$(brew --prefix)/opt/libsodium/lib:$LD_LIBRARY_PATH
    EOS
    chmod 0755, bin/"zeromq-env"
  end

  test do
    assert_predicate lib/"libzmq.so.5", :exist?
    assert_predicate include/"zmq.h", :exist?
  end
end
