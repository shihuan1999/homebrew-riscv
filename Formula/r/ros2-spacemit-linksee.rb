# riscv64_ohos prebuilt bottle — SpacemiT Robot SDK linksee (ament_cmake) @
# 2026-09-21: wheeled-robot launch/config set (base_control/odom/rplidar/ydlidar/
# voice_cmd) + rclpy nodes (odom_remap, asr, voice_cmd, voice_dispatcher).
# Chassis serial (esos) and lidar hardware are Bianbu-side; on OHOS drive the
# same launches from ros2_sim topics instead.
class Ros2SpacemitLinksee < Formula
  desc "SpacemiT linksee wheeled-robot ROS 2 launch/config + rclpy helper nodes"
  homepage "https://github.com/spacemit-robotics/linksee"
  url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles/ros2-spacemit-linksee-2026.09.21-ohos-riscv64.tar.gz"
  sha256 "7fbc71ce362f8e4c82a577c9f5a6be83fe3ad0ccf14ee6be78efff937a417c81"
  version "2026.09.21"
  license "Apache-2.0"

  depends_on "ros2-humble-full"

  bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "7fbc71ce362f8e4c82a577c9f5a6be83fe3ad0ccf14ee6be78efff937a417c81"
  end

  def install
    prefix.install Dir["*"]
  end

  def post_install
    fix_shebangs
    fix_exec_bits
    write_env
  end

  def fix_shebangs
    py = Formula["python"].opt_bin/"python3"
    (Dir["#{lib}/linksee/*.py"]).each do |f|
      next unless File.file?(f)
      head = File.open(f, "rb") { |io| io.read(64) }
      inreplace f, %r{^#!.*python3.*$}, "#!#{py}" if head.start_with?("#!/")
    end
  end

  def fix_exec_bits
    (Dir["#{lib}/linksee/*"]).each { |f| File.chmod(0755, f) if File.file?(f) }
  end

  def write_env
    (bin/"ros2-spacemit-linksee-env").write <<~EOS
      #!/bin/sh
      P=#{opt_prefix}
      export AMENT_PREFIX_PATH=$P:$AMENT_PREFIX_PATH
      export PYTHONPATH=$P/lib/python3.12/site-packages:$P/lib/python3.10/site-packages:$PYTHONPATH
      export PATH=$P/bin:$PATH
    EOS
    chmod 0755, bin/"ros2-spacemit-linksee-env"
  end

  def caveats
    <<~EOS
      Source after ros2-full-env:
        . "$(brew --prefix)/opt/ros2-spacemit-linksee/bin/ros2-spacemit-linksee-env"

      Nodes run directly: ros2 run linksee odom_remap_node.py
      Launches (hardware-free on OHOS): start_odom / voice_cmd
      Launches needing Bianbu hardware: base_control_esos, start_rplidar,
      start_ydlidar (esos chassis / serial lidars) — substitute ros2_sim.
    EOS
  end

  test do
    assert_predicate lib/"linksee/odom_remap_node.py", :exist?
    assert_predicate share/"linksee/launch/base_control_esos.launch.py", :exist?
    assert_predicate share/"linksee/launch/start_odom.launch.py", :exist?
  end
end
