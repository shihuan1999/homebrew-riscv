# riscv64_ohos prebuilt bottle — OpenCV 4.10.0 core libraries for OpenHarmony
# Cross-built headless (no GUI) with the spacemit musl toolchain:
# core/imgproc/imgcodecs/dnn/calib3d/features2d/flann/video/videoio/photo/stitching.
class Opencv < Formula
  desc "OpenCV 4.10 computer vision libraries (OpenHarmony riscv64, musl)"
  homepage "https://opencv.org/"
  url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles/opencv-4.10.0-ohos-riscv64.tar.gz"
  sha256 "849fc5a63d8e03e11b0ed62a1c0347ea6eb32b0a445a8db6066be13021867a39"
  version "4.10.0"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "849fc5a63d8e03e11b0ed62a1c0347ea6eb32b0a445a8db6066be13021867a39"
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
    (Dir["#{lib}/*"].to_a).each do |file|
      File.chmod(0755, file) if File.file?(file)
    end
  end

  def write_env
    bin.mkpath
    (bin/"opencv-env").write <<~EOS
      #!/bin/sh
      P=#{opt_prefix}
      export LD_LIBRARY_PATH=$P/lib:$LD_LIBRARY_PATH
      export OpenCV_DIR=$P/lib/cmake/opencv4
    EOS
    chmod 0755, bin/"opencv-env"
  end

  def caveats
    <<~EOS
      Source after your base environment:
        . "$(brew --prefix)/opt/opencv/bin/opencv-env"
    EOS
  end

  test do
    assert_predicate lib/"libopencv_core.so.4.10.0", :exist?
    assert_predicate lib/"libopencv_dnn.so.4.10.0", :exist?
  end
end
