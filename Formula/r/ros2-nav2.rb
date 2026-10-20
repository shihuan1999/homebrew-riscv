# riscv64_ohos prebuilt bottle — Nav2 navigation stack for ROS 2 Humble on OpenHarmony.
# AMCL, map_server/map_saver, NavFn/Theta*/RPP/DWB, behavior server, BT navigator,
# lifecycle manager, velocity smoother and nav2_simple_commander.
# GraphicsMagick was replaced by a minimal PGM/PPM reader/writer (OHOS has no GM).
class Ros2Nav2 < Formula
  desc "Nav2 navigation stack (AMCL, NavFn, DWB, BT navigator) for ROS 2 Humble on OHOS riscv64"
  homepage "https://navigation.ros.org/"
  url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles/ros2-nav2-1.1.20-riscv1-ohos-riscv64.tar.gz"
  sha256 "445d91775b1dc73b7e9109e971b59487efbe1af0d5901081bbed76d105ecbb9c"
  version "1.1.20"
  license "Apache-2.0"

  depends_on "ros2-humble-full"
  depends_on "ros2-slam"

  bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "09641dfe5b117d9f1fb4bf832b9bd5f7e81d4703d9b2296b3cf189261552cfd2"
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

      nav2_waypoint_follower is intentionally not included (needs cv_bridge/OpenCV).
      Maps are read/written as PGM/PPM only (no GraphicsMagick on OHOS).
    EOS
  end

  test do
    assert_predicate lib/"nav2_controller/controller_server", :exist?
    assert_predicate share/"nav2_bringup/launch/navigation_launch.py", :exist?
  end
end
