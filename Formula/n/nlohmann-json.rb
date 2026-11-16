# riscv64_ohos prebuilt bottle — nlohmann-json 3.11.3 (header-only + cmake config).
# Used by ros2_spacemit humanoid (operator protocol) and nav2_route style consumers.
class NlohmannJson < Formula
  desc "JSON for Modern C++ (header-only, riscv64_ohos keg)"
  homepage "https://github.com/nlohmann/json"
  url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles/nlohmann-json-3.11.3-ohos-riscv64.tar.gz"
  sha256 "410ee51e1220c5efb1bfa61e1bb10cab8350dd37716d4fdf8bbceb5535218c29"
  version "3.11.3"
  license "MIT"

  bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "410ee51e1220c5efb1bfa61e1bb10cab8350dd37716d4fdf8bbceb5535218c29"
  end

  def install
    prefix.install Dir["*"]
  end

  test do
    assert_predicate include/"nlohmann/json.hpp", :exist?
  end
end
