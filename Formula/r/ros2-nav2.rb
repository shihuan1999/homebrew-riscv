# riscv64_ohos prebuilt bottle — Nav2 navigation stack for ROS 2 Humble on OpenHarmony.
# AMCL, map_server/map_saver, NavFn/Theta*/RPP/DWB, behavior server, BT navigator,
# lifecycle manager, velocity smoother and nav2_simple_commander.
# GraphicsMagick was replaced by a minimal PGM/PPM reader/writer (OHOS has no GM).
# riscv3 adds SmacPlanner (bundled OMPL), MPPI controller, route server,
# graceful controller, collision monitor, waypoint follower, laser_filters
# and pointcloud_to_laserscan.
class Ros2Nav2 < Formula
  desc "Nav2 navigation stack (AMCL, NavFn, DWB, BT navigator) for ROS 2 Humble on OHOS riscv64"
  homepage "https://navigation.ros.org/"
  url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles/ros2-nav2-1.1.20-riscv3-ohos-riscv64.tar.gz"
  sha256 "618a4aec4ce85ebb14af0cc453b145496a3ed0b3efe4106b08a403f17f772eeb"
  version "1.1.20-riscv3"
  license "Apache-2.0"

  depends_on "ros2-humble-full"
  depends_on "ros2-slam"

  bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "1a0bfc7894d92323c9102530d07fa707203c732867097c1764485f6a431907e7"
  end

  def install
    prefix.install Dir["*"]
    write_env
  end

  def post_install
    fix_exec_bits
    write_env
  end

  # Bottles built from a Windows checkout lose the exec bit; restore it.
  def fix_exec_bits
    (Dir["#{bin}/*"] + Dir["#{lib}/*/*"]).each do |file|
      File.chmod(0755, file) if File.file?(file)
    end
  end

  def write_env
    python = Formula["python"].opt_bin/"python3"

    (Dir["#{bin}/*"] + Dir["#{lib}/**/*"]).each do |file|
      next unless File.file?(file)
      head = File.open(file, "rb") { |io| io.read(64) } || ""
      next unless head.start_with?("#!/usr/bin/python3")
      inreplace file, "#!/usr/bin/python3", "#!#{python}"
    end

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

      Extra planners/controllers in this build: SmacPlanner2D/Hybrid/Lattice
      (OMPL bundled), MPPI controller, graceful controller, collision monitor,
      route server, waypoint_follower (photo_at_waypoint plugin removed since
      it needs cv_bridge/OpenCV), laser_filters and pointcloud_to_laserscan.
      Maps are read/written as PGM/PPM only (no GraphicsMagick on OHOS).
    EOS
  end

  test do
    assert_predicate lib/"nav2_controller/controller_server", :exist?
    assert_predicate share/"nav2_bringup/launch/navigation_launch.py", :exist?
  end
end
