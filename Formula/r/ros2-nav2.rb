# riscv64_ohos prebuilt dist — Nav2 navigation stack for ROS 2 Humble on OpenHarmony.
# AMCL, map_server/map_saver, NavFn/Theta*/RPP/DWB, behavior server, BT navigator,
# lifecycle manager, velocity smoother and nav2_simple_commander.
# GraphicsMagick was replaced by a minimal PGM/PPM reader/writer (OHOS has no GM).
class Ros2Nav2 < Formula
  desc "Nav2 navigation stack (AMCL, NavFn, DWB, BT navigator) for ROS 2 Humble on OHOS riscv64"
  homepage "https://navigation.ros.org/"
  url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles/ros2-nav2-1.1.20-riscv1-ohos-riscv64.tar.gz"
  sha256 "445d91775b1dc73b7e9109e971b59487efbe1af0d5901081bbed76d105ecbb9c"
  version "1.1.20-riscv1"
  license "Apache-2.0"

  depends_on "ros2-humble-full"
  depends_on "ros2-slam"

  def install
    prefix.install Dir["*"]

    (bin/"ros2-nav2-env").write <<~EOS
      #!/bin/sh
      P=#{opt_prefix}
      export AMENT_PREFIX_PATH=$P:$AMENT_PREFIX_PATH
      export PYTHONPATH=$P/lib/python3.12/site-packages:$P/lib/python3.10/site-packages:$PYTHONPATH
      export LD_LIBRARY_PATH=$P/lib:$LD_LIBRARY_PATH
      export PATH=$P/bin:$PATH
    EOS
    chmod 0755, bin/"ros2-nav2-env"
  end

  def caveats
    <<~EOS
      Source after ros2-full-env and ros2-slam-env:
        . "$(brew --prefix)/opt/ros2-humble-full/bin/ros2-full-env"
        . "$(brew --prefix)/opt/ros2-slam/bin/ros2-slam-env"
        . "$(brew --prefix)/opt/ros2-nav2/bin/ros2-nav2-env"

      nav2_waypoint_follower is intentionally not included (needs cv_bridge/OpenCV).
      Maps are read/written as PGM/PPM only (no GraphicsMagick on OHOS).
    EOS
  end

  test do
    assert_predicate lib/"nav2_controller/controller_server", :exist?
    assert_predicate share/"nav2_bringup/launch/navigation_launch.py", :exist?
  end
end
