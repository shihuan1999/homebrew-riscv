# riscv64_ohos prebuilt bottle — vision overlay for ROS 2 Humble on OpenHarmony
# cv_bridge (C++ core), image_transport + compressed/depth plugins,
# image_pipeline (image_proc/image_publisher, no image_view), vision_msgs,
# camera_calibration_parsers + camera_info_manager, tracetools(+_image_pipeline).
class Ros2Vision < Formula
  desc "cv_bridge + image_transport/pipeline vision overlay for ROS 2 (OpenHarmony riscv64)"
  homepage "https://github.com/ros-perception/vision_opencv"
  url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles/ros2-vision-2026.11.17-ohos-riscv64.tar.gz"
  sha256 "d87ac243ca30ef1bd231c8c12cf4014f64e04b77c8f21c09f0a43b413bec6f23"
  version "2026.11.17"
  license "Apache-2.0"

  depends_on "ros2-humble-full"
  depends_on "opencv"

  bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "d87ac243ca30ef1bd231c8c12cf4014f64e04b77c8f21c09f0a43b413bec6f23"
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
    (Dir["#{lib}/*/*"].to_a + Dir["#{lib}/*"]).each do |file|
      File.chmod(0755, file) if File.file?(file)
    end
  end

  def write_env
    bin.mkpath
    (bin/"ros2-vision-env").write <<~EOS
      #!/bin/sh
      P=#{opt_prefix}
      export AMENT_PREFIX_PATH=$P:$AMENT_PREFIX_PATH
      export PYTHONPATH=$P/lib/python3.12/site-packages:$P/lib/python3.10/site-packages:$PYTHONPATH
      export LD_LIBRARY_PATH=$P/lib:$LD_LIBRARY_PATH
      export PATH=$P/bin:$PATH
    EOS
    chmod 0755, bin/"ros2-vision-env"
  end

  def caveats
    <<~EOS
      Source this after the ROS 2 base + opencv environments:
        . "$(brew --prefix)/opt/ros2-humble-full/bin/ros2-full-env"
        . "$(brew --prefix)/opt/opencv/bin/opencv-env"
        . "$(brew --prefix)/opt/ros2-vision/bin/ros2-vision-env"

      Quick check:
        ros2 pkg list | grep -e cv_bridge -e image_transport
    EOS
  end

  test do
    assert_predicate lib/"libcv_bridge.so", :exist?
    assert_predicate lib/"image_proc/image_proc", :exist?
    assert_predicate share/"vision_msgs", :exist?
  end
end
