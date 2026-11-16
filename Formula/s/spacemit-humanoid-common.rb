# riscv64_ohos prebuilt bottle — SpacemiT Robot SDK humanoid_common core libs
# (robot_base / transport_executor / operator_client + offline test bins).
# Built from github.com/spacemit-robotics/humanoid_common @ 2026-11-13 with
# OpenSSL/web assets and RL backends gated out (no OpenSSL in the OHOS musl
# sysroot; RL needs onnxruntime, tracked separately).
class SpacemitHumanoidCommon < Formula
  desc "SpacemiT humanoid_common core libs: robot_base, transport_executor, operator_client"
  homepage "https://github.com/spacemit-robotics/humanoid_common"
  url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles/spacemit-humanoid-common-2026.11.13-ohos-riscv64.tar.gz"
  sha256 "f1beaa330e584f0e43993f87f7f650f453f1dd1fa7a1b89cb6ac41132e06fb65"
  version "2026.11.13"
  license "Apache-2.0"

  depends_on "ros2-humble-full" # libyaml-cpp.so runtime

  bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "f1beaa330e584f0e43993f87f7f650f453f1dd1fa7a1b89cb6ac41132e06fb65"
  end

  def install
    prefix.install Dir["*"]
  end

  def post_install
    fix_exec_bits
    (bin/"spacemit-humanoid-common-env").write <<~EOS
      #!/bin/sh
      P=#{opt_prefix}
      export LD_LIBRARY_PATH=$P/lib:$(brew --prefix)/opt/ros2-humble-full/lib:$LD_LIBRARY_PATH
      export PATH=$P/bin:$PATH
    EOS
    chmod 0755, bin/"spacemit-humanoid-common-env"
  end

  def fix_exec_bits
    (Dir["#{bin}/*"]).each { |f| File.chmod(0755, f) if File.file?(f) }
  end

  def caveats
    <<~EOS
      Source after ros2-full-env:
        . "$(brew --prefix)/opt/spacemit-humanoid-common/bin/spacemit-humanoid-common-env"

      Offline checks: test_robot_base, test_transport_executor, hmi_tui,
      humanoid_operator_mcp. OpenSSL-gated operator_service/hmi_runtime and
      RL/MuJoCo runtimes are intentionally absent on OHOS/musl.
    EOS
  end

  test do
    assert_predicate lib/"librobot_base.so", :exist?
    assert_predicate lib/"libtransport_executor.so", :exist?
    assert_predicate lib/"liboperator_client.so", :exist?
    assert_predicate bin/"test_robot_base", :exist?
  end
end
