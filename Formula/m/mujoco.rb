# riscv64_ohos prebuilt bottle — MuJoCo 3.4.0 physics engine (headless core)
# Cross-built with the spacemit musl toolchain; physics/serialization only
# (simulate/studio GUI targets disabled — no GL/X11 on target).
class Mujoco < Formula
  desc "MuJoCo 3.4 physics engine core library (OpenHarmony riscv64, musl)"
  homepage "https://mujoco.org/"
  url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles/mujoco-3.4.0-ohos-riscv64.tar.gz"
  sha256 "a2611a8b00301c4c32ff70eedb3f9c7f6d068a64625f595b27e91682bad17129"
  version "3.4.0"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "a2611a8b00301c4c32ff70eedb3f9c7f6d068a64625f595b27e91682bad17129"
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
    (bin/"mujoco-env").write <<~EOS
      #!/bin/sh
      P=#{opt_prefix}
      export LD_LIBRARY_PATH=$P/lib:$LD_LIBRARY_PATH
    EOS
    chmod 0755, bin/"mujoco-env"
  end

  def caveats
    <<~EOS
      Source after your base environment:
        . "$(brew --prefix)/opt/mujoco/bin/mujoco-env"
      Headless build: physics + MJCF/XML serialization only (no GL rendering).
    EOS
  end

  test do
    assert_predicate lib/"libmujoco.so.3.4.0", :exist?
    assert_predicate share/"mujoco/model", :exist?
  end
end
