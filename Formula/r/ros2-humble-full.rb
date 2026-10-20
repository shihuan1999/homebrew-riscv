# riscv64_ohos prebuilt dist — ROS2 Humble full robot stack (230 pkgs: rclpy, ros2cli,
# launch, tf2/geometry2, urdf/robot_state_publisher, ros2_control, teleop, rosbag2,
# diagnostics, rosbridge) for OpenHarmony
class Ros2HumbleFull < Formula
  desc "ROS 2 Humble full robot stack (rclpy/ros2cli/tf2/ros2_control/rosbridge) for OpenHarmony riscv64"
  homepage "https://docs.ros.org/en/humble/"
  url "https://github.com/ros2/ros2/archive/refs/heads/humble.tar.gz"
  sha256 "38c41a252286332331c133dda935ed13fc7d17bea74f50b1b447934cea347dfe"
  version "16.0.21-riscv1"

  depends_on "python"

  bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "d48f2a99a636b6903b89826cc6834367ec4f2dbf246cc318cdbf1dcb8f60b193"
  end

  resource "ohos_riscv64_dist" do
    url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles/ros2-humble-full-16.0.21-riscv1-ohos-riscv64.tar.gz"
    sha256 "04c14ab329bebaecb46725f09703de8e1c6e493ff88f142f37f34a8783c155c5"
  end

  def install
    resource("ohos_riscv64_dist").stage do
      prefix.install Dir["install/*"]
    end
    write_env_and_fix_shebangs
  end

  # Bottles are poured, not installed, so repeat the OHOS fixes after pour.
  def post_install
    write_env_and_fix_shebangs
  end

  def write_env_and_fix_shebangs
    python = Formula["python"].opt_bin/"python3"

    (Dir["#{bin}/*"] + Dir["#{lib}/**/*"]).each do |file|
      next unless File.file?(file)
      head = File.open(file, "rb") { |io| io.read(64) } || ""
      next unless head.start_with?("#!/usr/bin/python3")
      inreplace file, "#!/usr/bin/python3", "#!#{python}"
    end

    (bin/"ros2-full-env").write <<~EOS
      #!/bin/sh
      # ROS 2 Humble full robot stack environment (OpenHarmony riscv64)
      export PYTHONHOME=
      export ROS2_HOME=#{opt_prefix}
      export AMENT_PREFIX_PATH=#{opt_prefix}:$AMENT_PREFIX_PATH
      export PYTHONPATH=#{opt_prefix}/lib/python3.12/site-packages:#{opt_prefix}/lib/python3.10/site-packages:$PYTHONPATH
      export LD_LIBRARY_PATH=#{opt_prefix}/lib:#{Formula["python"].opt_lib}:$LD_LIBRARY_PATH
      export PATH=#{opt_prefix}/bin:#{Formula["python"].opt_bin}:#{opt_prefix}/lib/robot_state_publisher:#{opt_prefix}/lib/controller_manager:$PATH
      export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
      export ROS_PYTHON_VERSION=3
    EOS
    chmod 0755, bin/"ros2-full-env"
  end

  def caveats
    <<~EOS
      Source the env before use:
        . "$(brew --prefix)/opt/ros2-humble-full/bin/ros2-full-env"

      Python message modules need numpy (riscv64 wheel from this tap):
        brew install ros2-humble-full already pulls hbrew/riscv/python.
      For CLI/launch support also install catkin_pkg, lark, argcomplete,
      packaging, pyyaml, tornado and netifaces into that Python.
    EOS
  end

  test do
    assert_predicate bin/"ros2", :exist?
    assert_predicate share/"rclcpp", :exist?
  end
end
