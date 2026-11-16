# riscv64_ohos prebuilt bottle — SpacemiT Robot SDK ros2_humanoid (ament pkg
# "humanoid") @ 2026-11-12: g1/linglong cmd_vel bridges, body/head/fact TF nodes,
# tf_to_odom, nav RL bridge + 41 launch/config files. rtabmap/realsense exec deps
# are Bianbu-only; navigation launches pair with the local nav2/slam stack.
class Ros2SpacemitHumanoid < Formula
  desc "SpacemiT humanoid ROS 2 wrappers: cmd_vel bridge, dynamic TF, nav launches"
  homepage "https://github.com/spacemit-robotics/ros2_humanoid"
  url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles/ros2-spacemit-humanoid-2026.11.12-ohos-riscv64.tar.gz"
  sha256 "4952ec8b34da3f77d327ec133129303afa1c5946b277b9f2f7ad3be337b5315d"
  version "2026.11.12"
  license "Apache-2.0"

  depends_on "ros2-humble-full"
  depends_on "spacemit-humanoid-common"
  depends_on "zeromq"
  depends_on "nlohmann-json"

  bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "4952ec8b34da3f77d327ec133129303afa1c5946b277b9f2f7ad3be337b5315d"
  end

  def install
    prefix.install Dir["*"]
  end

  def post_install
    fix_exec_bits
    write_env
  end

  def fix_exec_bits
    (Dir["#{lib}/humanoid/*"]).each { |f| File.chmod(0755, f) if File.file?(f) }
  end

  def write_env
    (bin/"ros2-spacemit-humanoid-env").write <<~EOS
      #!/bin/sh
      P=#{opt_prefix}
      HB=$(brew --prefix)
      export AMENT_PREFIX_PATH=$P:$AMENT_PREFIX_PATH
      export LD_LIBRARY_PATH=$P/lib:$HB/opt/spacemit-humanoid-common/lib:$HB/opt/ros2-humble-full/lib:$LD_LIBRARY_PATH
      export PATH=$P/bin:$PATH
    EOS
    chmod 0755, bin/"ros2-spacemit-humanoid-env"
  end

  def caveats
    <<~EOS
      Source after ros2-full-env:
        . "$(brew --prefix)/opt/ros2-spacemit-humanoid/bin/ros2-spacemit-humanoid-env"

      Nodes: g1_cmd_vel_bridge / humanoid_nav_rl_bridge / humanoid_cmd_vel_hmi
             g1_body_tf / humanoid_head_tf / tf_to_odom
      Launch set: g1_*/linglong_* (cmd_vel bridge, body/fact/head tf, rgbd slam,
      rgbd nav2, lidar odom, nav rl bridge).
      rtabmap/RealSense parts of upstream launches target Bianbu hardware; on
      OHOS pair these with ros2-sim / ros2-slam / ros2-nav2 instead.
    EOS
  end

  test do
    assert_predicate lib/"humanoid/g1_cmd_vel_bridge_node", :exist?
    assert_predicate lib/"humanoid/tf_to_odom_node", :exist?
    assert_predicate share/"humanoid/launch/g1_cmd_vel_bridge.launch.py", :exist?
    assert_predicate share/"humanoid/launch/linglong_rgbd_slam.launch.py", :exist?
  end
end
