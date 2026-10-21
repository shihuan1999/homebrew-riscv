# riscv64_ohos prebuilt bottle — extra ros2_control controllers and IMU tools.
# Beyond the controllers already in ros2-humble-full (joint_state_broadcaster,
# forward_command, diff_drive, joint_trajectory): steering/ackermann/bicycle/
# tricycle/mecanum drive controllers, pid/gpio/effort/position/velocity/gripper
# controllers, pose/range/force-torque/IMU broadcasters, imu_complementary_filter
# and imu_filter_madgwick, plus ackermann_msgs.
class Ros2Controllers < Formula
  desc "ros2_control controllers (steering/mecanum/pid/gpio) + IMU filters for OHOS riscv64"
  homepage "https://github.com/ros-controls/ros2_controllers"
  url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles/ros2-controllers-4.15.0-riscv1-ohos-riscv64.tar.gz"
  sha256 "fa3eccdac324f77bec4a2e9a054c50a9df1b61eb57941ee0e09e22c516e62921"
  version "4.15.0-riscv1"
  license "Apache-2.0"

  depends_on "ros2-humble-full"

  bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "ceadd2b8098aed0bd5d61a1a1dd239b38ea21b5d35ef13ecb2243081770d0492"
  end

  def install
    prefix.install Dir["*"]
    write_env
  end

  def post_install
    fix_exec_bits
    write_env
  end

  def fix_exec_bits
    (Dir["#{bin}/*"] + Dir["#{lib}/*/*"]).each do |file|
      File.chmod(0755, file) if File.file?(file)
    end
  end

  def write_env
    (bin/"ros2-controllers-env").write <<~EOS
      #!/bin/sh
      P=#{opt_prefix}
      export AMENT_PREFIX_PATH=$P:$AMENT_PREFIX_PATH
      export PYTHONPATH=$P/lib/python3.12/site-packages:$PYTHONPATH
      export LD_LIBRARY_PATH=$P/lib:$LD_LIBRARY_PATH
    EOS
    chmod 0755, bin/"ros2-controllers-env"
  end

  def caveats
    <<~EOS
      Source after ros2-full-env:
        . "$(brew --prefix)/opt/ros2-humble-full/bin/ros2-full-env"
        . "$(brew --prefix)/opt/ros2-controllers/bin/ros2-controllers-env"

      Included: diff_drive, steering/ackermann/bicycle/tricycle, mecanum,
      pid, gpio, effort/position/velocity/gripper, joint_trajectory,
      joint_state_broadcaster, pose/range/force-torque/imu broadcasters,
      imu_complementary_filter, imu_filter_madgwick, ackermann_msgs.
    EOS
  end

  test do
    assert_predicate share/"diff_drive_controller", :exist?
    assert_predicate share/"imu_filter_madgwick", :exist?
  end
end
