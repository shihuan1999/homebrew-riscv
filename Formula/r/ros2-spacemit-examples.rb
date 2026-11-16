# riscv64_ohos prebuilt bottle — SpacemiT Robot SDK ROS 2 wrapper packages, vendored.
# Upstream: github.com/spacemit-robotics (ros2_slam_toolbox_run, ros2_nav2,
# ros2_simulation @ 2026-11-03).  Launch/config files and the nav2 python helpers
# are installed as ament packages; the humanoid_mujoco C++ sim driver needs the
# MuJoCo port (separate keg), so this bottle carries its launch/config only.
class Ros2SpacemitExamples < Formula
  desc "SpacemiT robot SDK ROS 2 wrappers (slam_toolbox_run, nav2, humanoid_mujoco configs)"
  homepage "https://github.com/spacemit-robotics"
  url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles/ros2-spacemit-examples-2026.11.16-ohos-riscv64.tar.gz"
  sha256 "1bb80a2fb41fde07bb26c3ea829ff34fb252214db3fb09682713d050ac2ff7f9"
  version "2026.11.16"
  license "Apache-2.0"

  depends_on "ros2-humble-full"
  depends_on "ros2-slam"
  depends_on "ros2-nav2"

  bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "1bb80a2fb41fde07bb26c3ea829ff34fb252214db3fb09682713d050ac2ff7f9"
  end

  def install
    prefix.install Dir["*"]
    write_env
  end

  def post_install
    fix_shebangs
    fix_exec_bits
    write_env
  end

  def fix_shebangs
    py = Formula["python"].opt_bin/"python3"
    dirs = Dir["#{lib}/slam_toolbox_run/*"].to_a + Dir["#{lib}/nav2/*"].to_a
    dirs.each do |f|
      next unless File.file?(f)
      head = File.open(f, "rb") { |io| io.read(64) }
      inreplace f, %r{^#!.*python3.*$}, "#!#{py}" if head.start_with?("#!/")
    end
  end

  def fix_exec_bits
    (Dir["#{lib}/slam_toolbox_run/*"] + Dir["#{lib}/nav2/*"]).each do |f|
      File.chmod(0755, f) if File.file?(f)
    end
  end

  def write_env
    (bin/"ros2-spacemit-env").write <<~EOS
      #!/bin/sh
      P=#{opt_prefix}
      export AMENT_PREFIX_PATH=$P:$AMENT_PREFIX_PATH
      export PYTHONPATH=$P/lib/python3.12/site-packages:$P/lib/python3.10/site-packages:$PYTHONPATH
      export PATH=$P/bin:$PATH
    EOS
    chmod 0755, bin/"ros2-spacemit-env"
  end

  def caveats
    <<~EOS
      Vendored from spacemit-robotics 2026-11-16 snapshot
      (see share/spacemit_robotics/MANIFEST.json):
        ros2_slam_toolbox_run  slam_toolbox launch/config wrappers
        ros2_nav2              nav2 launch/config + map + autonomous_patrol node
        ros2_simulation        humanoid_mujoco launch/config @ 2026-11-03
        (g1/linglong rgbd+lidar bringup/sim/slam/nav2, 12 launches)
      MuJoCo C++ sim driver itself ships in the mujoco keg (P2).

      Source ros2-full-env, ros2-slam-env, ros2-nav2-env, then this env.
    EOS
  end

  test do
    assert_predicate share/"slam_toolbox_run/launch/online_async_launch.py", :exist?
    assert_predicate share/"nav2/launch/nav2.launch.py", :exist?
    assert_predicate share/"humanoid_mujoco/launch/g1_rgbd_bringup.launch.py", :exist?
    assert_predicate share/"humanoid_mujoco/config/g1_rgbd_nav2.yaml", :exist?
  end
end
