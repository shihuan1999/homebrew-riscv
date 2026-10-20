# riscv64_ohos — headless 2D differential-drive robot simulator for ROS 2 Humble.
# Publishes /scan, /odom, /joint_states and odom->base_footprint TF and consumes
# /cmd_vel, so SLAM and Nav2 can be exercised on a K3 board without hardware or Gazebo.
class Ros2Sim < Formula
  desc "Headless 2D robot simulator + SLAM/Nav2 demos for ROS 2 Humble on OHOS riscv64"
  homepage "https://github.com/shihuan1999/homebrew-riscv"
  url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles/ros2-sim-0.1.0-ohos-riscv64.tar.gz"
  sha256 "1bffc83efb3a946f2a955dbfbd70c4ccd213cd849b800f6868db421169f8777f"
  version "0.1.0"
  license "Apache-2.0"

  depends_on "ros2-humble-full"

  def install
    prefix.install Dir["*"]

    (bin/"ros2-sim-env").write <<~EOS
      #!/bin/sh
      P=#{opt_prefix}
      export AMENT_PREFIX_PATH=$P:$AMENT_PREFIX_PATH
      export PATH=$P/bin:$PATH
    EOS
    chmod 0755, bin/"ros2-sim-env"
  end

  def caveats
    <<~EOS
      Source after ros2-full-env (and ros2-slam-env if you want mapping):
        . "$(brew --prefix)/opt/ros2-humble-full/bin/ros2-full-env"
        . "$(brew --prefix)/opt/ros2-sim/bin/ros2-sim-env"

      Simulator only:      ros2 launch ros2_sim robot_sim.launch.py
      Simulator + SLAM:    ros2 launch ros2_sim slam_sim.launch.py
      One-shot SLAM demo:  sh "$(brew --prefix)/opt/ros2-sim/share/ros2_sim/demos/demo_slam.sh" 60
    EOS
  end

  test do
    assert_predicate lib/"ros2_sim/robot-sim", :exist?
    assert_predicate share/"ros2_sim/launch/slam_sim.launch.py", :exist?
  end
end
