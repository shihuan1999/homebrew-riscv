# riscv64_ohos — SpacemiT Robot SDK ROS 2 wrapper packages, vendored for OHOS.
# Upstream: github.com/spacemit-robotics (ros2_slam_toolbox_run, ros2_nav2,
# ros2_simulation).  Launch/config files and the nav2 python helpers are installed
# as ament packages; the humanoid MuJoCo node itself is not portable to OHOS, so
# use hbrew/riscv/ros2-sim for headless simulation.
class Ros2SpacemitExamples < Formula
  desc "SpacemiT robot SDK ROS 2 wrappers (slam_toolbox_run, nav2, humanoid_mujoco configs)"
  homepage "https://github.com/spacemit-robotics"
  url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles/ros2-spacemit-examples-2026.10.15-ohos-riscv64.tar.gz"
  sha256 "8c10072ad7d61c89315112432c46e9e3c4362fc3f6a705921fd81aea252df612"
  version "2026.10.15"
  license "Apache-2.0"

  depends_on "ros2-humble-full"
  depends_on "ros2-slam"
  depends_on "ros2-nav2"

  def install
    prefix.install Dir["*"]

    (bin/"ros2-spacemit-env").write <<~EOS
      #!/bin/sh
      P=#{opt_prefix}
      export AMENT_PREFIX_PATH=$P:$AMENT_PREFIX_PATH
      export PYTHONPATH=$P/lib/python3.12/site-packages:$PYTHONPATH
    EOS
    chmod 0755, bin/"ros2-spacemit-env"
  end

  def caveats
    <<~EOS
      Vendored from spacemit-robotics (see share/spacemit_robotics/MANIFEST.json):
        ros2_slam_toolbox_run  slam_toolbox_run launch/config wrappers
        ros2_nav2              nav2 launch/config + map + autonomous_patrol node
        ros2_simulation        humanoid_mujoco launch/config (MuJoCo runtime not on OHOS)

      Source ros2-full-env, ros2-slam-env, ros2-nav2-env, then this env.
    EOS
  end

  test do
    assert_predicate share/"slam_toolbox_run/launch/online_async_launch.py", :exist?
    assert_predicate share/"nav2/launch/nav2.launch.py", :exist?
  end
end
