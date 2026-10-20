# riscv64_ohos prebuilt bottle — SLAM overlay for ROS 2 Humble on OpenHarmony
# slam_toolbox (async/sync/localization/lifelong/map_and_localization) +
# robot_localization (EKF/UKF/navsat) + interactive_markers + tf2 extras.
class Ros2Slam < Formula
  desc "slam_toolbox + robot_localization SLAM overlay for ROS 2 Humble (OpenHarmony riscv64)"
  homepage "https://github.com/SteveMacenski/slam_toolbox"
  url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles/ros2-slam-0.2.0-ohos-riscv64.tar.gz"
  sha256 "e37af3a722571232970b451fd4675af6b1f48bbe075d1f52a623649b55aadc9a"
  version "0.2.0"
  license "LGPL-2.1-or-later"

  depends_on "ros2-humble-full"

  bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "f5fd499937092f0ad99797d288c9a6db30ba3cfad2db3fedcf2e02a4d6c2a268"
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
    (bin/"ros2-slam-env").write <<~EOS
      #!/bin/sh
      P=#{opt_prefix}
      export AMENT_PREFIX_PATH=$P:$AMENT_PREFIX_PATH
      export PYTHONPATH=$P/lib/python3.12/site-packages:$P/lib/python3.10/site-packages:$PYTHONPATH
      export LD_LIBRARY_PATH=$P/lib:$LD_LIBRARY_PATH
      export PATH=$P/bin:$PATH
    EOS
    chmod 0755, bin/"ros2-slam-env"
  end

  def caveats
    <<~EOS
      Source this after the ROS 2 base environment:
        . "$(brew --prefix)/opt/ros2-humble-full/bin/ros2-full-env"
        . "$(brew --prefix)/opt/ros2-slam/bin/ros2-slam-env"

      Quick check:
        ros2 pkg list | grep slam_toolbox
    EOS
  end

  test do
    assert_predicate share/"slam_toolbox/launch/online_async_launch.py", :exist?
    assert_predicate lib/"slam_toolbox/async_slam_toolbox_node", :exist?
  end
end
