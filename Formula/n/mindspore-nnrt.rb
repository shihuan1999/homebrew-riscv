# mindspore-nnrt: OpenHarmony Neural Network Runtime (NNRT) client libraries
# for riscv64, cross-built from the OH 6.1 tree (foundation/ai/
# neural_network_runtime) with the spacemit musl clang 21 toolchain, plus the
# NNRT proxy backends. Stock K3 pico images ship no NNRT system service / HDI
# driver (no NPU), so on-device these link as libraries only: the mslite NNRT
# delegate loads them, finds no backend and cleanly falls back to the CPU
# provider (verified on hardware). Install this to build/link apps targeting
# NNRT-equipped images.
class MindsporeNnrt < Formula
  desc "OpenHarmony 6.1 Neural Network Runtime client libs + proxy backends (riscv64)"
  homepage "https://gitee.com/openharmony/neural_network_runtime"
  url "https://github.com/shihuan1999/riscv-bin/releases/download/bottles-v1.0/mindspore-nnrt-6.1.0-k3.1.riscv64_ohos.bottle.tar.gz"
  sha256 "58491fc698da9d47e766b9f4c223defa26ca310e16d5bca1478d735c999dd4ce"
  version "6.1.0-k3.1"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/bottles-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "58491fc698da9d47e766b9f4c223defa26ca310e16d5bca1478d735c999dd4ce"
  end

  def install
    Dir["mindspore-nnrt/*/*"].each { |e| prefix.install e }
  end

  def caveats
    <<~EOS
      Requires an image with the NNRT system service + HDI driver to do
      anything at runtime. Stock K3 pico images do not ship them (no NPU);
      use the mindspore-lite CPU provider (RVV-enabled) for on-device
      inference on K3. See share/mindspore-nnrt/README.md.
    EOS
  end

  test do
    %w[libneural_network_runtime.so libneural_network_core.so].each do |so|
      assert File.exist?(lib/so), "#{so} missing"
    end
  end
end
