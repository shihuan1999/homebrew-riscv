# riscv64_ohos prebuilt dist — ROS2 Humble (113 pkgs, rcl/rclcpp + CycloneDDS) for OpenHarmony
class Ros2Humble < Formula
  desc "ROS 2 Humble (rcl/rclcpp + CycloneDDS, demo_nodes_cpp) for OpenHarmony riscv64"
  homepage "https://docs.ros.org/en/humble/"
  url "https://github.com/ros2/ros2/archive/refs/heads/humble.tar.gz"
  sha256 "38c41a252286332331c133dda935ed13fc7d17bea74f50b1b447934cea347dfe"
  version "16.0.20-riscv1"

  bottle do
    root_url "http://10.0.50.17:8090/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "f47791cb7232aa37b44ec1cc4dcc2af72ce653a4ef8e5ae8ae1a7fcb272e1841"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/ros2-humble-16.0.20-riscv1-ohos-riscv64.tar.gz"
    sha256 "93320bd7413e4fe2062a96c5c7ebb467a888da236f207f12aa4f5427bec590f5"
  end

  def install
    resource("ohos_riscv64_dist").stage do
      prefix.install Dir["*"]
    end
  end

  test do
    system "true"
  end
end
