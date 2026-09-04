# riscv64_ohos prebuilt dist — ROS2 Humble full robot stack (230 pkgs: rclpy, ros2cli,
# launch, tf2/geometry2, urdf/robot_state_publisher, ros2_control, teleop, rosbag2,
# diagnostics, rosbridge) for OpenHarmony
class Ros2HumbleFull < Formula
  desc "ROS 2 Humble full robot stack (rclpy/ros2cli/tf2/ros2_control/rosbridge) for OpenHarmony riscv64"
  homepage "https://docs.ros.org/en/humble/"
  url "https://github.com/ros2/ros2/archive/refs/heads/humble.tar.gz"
  sha256 "38c41a252286332331c133dda935ed13fc7d17bea74f50b1b447934cea347dfe"
  version "16.0.21-riscv1"

  bottle do
    root_url "http://10.0.50.17:8090/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "d48f2a99a636b6903b89826cc6834367ec4f2dbf246cc318cdbf1dcb8f60b193"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/ros2-humble-full-16.0.21-riscv1-ohos-riscv64.tar.gz"
    sha256 "04c14ab329bebaecb46725f09703de8e1c6e493ff88f142f37f34a8783c155c5"
  end

  def install
    resource("ohos_riscv64_dist").stage do
      prefix.install Dir["install/*"]
    end

    (bin/"ros2-full-env").write <<~EOS
      #!/bin/sh
      # ROS 2 Humble full robot stack environment (OpenHarmony riscv64)
      export ROS2_HOME=#{prefix}
      export AMENT_PREFIX_PATH=#{prefix}:$AMENT_PREFIX_PATH
      export PYTHONPATH=#{prefix}/lib/python3.12/site-packages:#{prefix}/lib/python3.10/site-packages:$PYTHONPATH
      export LD_LIBRARY_PATH=#{prefix}/lib:$LD_LIBRARY_PATH
      export PATH=#{prefix}/bin:#{prefix}/lib/robot_state_publisher:#{prefix}/lib/controller_manager:$PATH
      export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
      export ROS_PYTHON_VERSION=3
      export PYTHONHOME=
    EOS
  end

  def caveats
    <<~EOS
      Source the env before use:
        source "$(brew --prefix)/opt/ros2-humble-full/bin/ros2-full-env"

      Requires device python3.12 at /data/python312 plus pure-python deps:
        pip install catkin_pkg netifaces lark tornado 'bson(pymongo)' cbor2==5.6.5
    EOS
  end

  test do
    system "true"
  end
end
