# mindspore-lite: MindSpore Lite 2.4 inference runtime for OpenHarmony riscv64
# (SpacemiT K3 pico), cross-built with the spacemit musl clang 21 toolchain
# (-march=rv64gcv, RVV 1.0). Includes a custom autovectorized 12x8 tile gemm
# patched into nnacl (MatMulOpt -> Matmul12x8Rvv) that lifts fp32 MatMul /
# transformer-block throughput ~5x vs the upstream reference kernel:
#   matmul 128x896x4864 fp32: 10.7 GFLOP/s  (X100 cluster, 8T)
#   transformer block seq128: 10.1 GFLOP/s  (X100 cluster, 8T)
#   gemv 896x4864 fp32:      13.6 GB/s     (vs llama.cpp tg ~10.6 GB/s)
# Numbers verified on hardware against onnxruntime references (cosine=1.0).
class MindsporeLite < Formula
  desc "MindSpore Lite 2.4 inference runtime + benchmark/verify tools (RVV-accelerated)"
  homepage "https://www.mindspore.cn/lite"
  url "https://github.com/shihuan1999/riscv-bin/releases/download/bottles-v1.0/mindspore-lite-2.4.0-k3.1.riscv64_ohos.bottle.tar.gz"
  sha256 "2c8513981d06eb9fa6aeb757bcf859e2c4c93eaf8cb41d53f7c395f20b959b15"
  version "2.4.0-k3.1"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/bottles-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "2c8513981d06eb9fa6aeb757bcf859e2c4c93eaf8cb41d53f7c395f20b959b15"
  end

  def install
    # tar layout: mindspore-lite/<version>/{bin,libexec,lib,include,share}
    Dir["mindspore-lite/*/*"].each { |e| prefix.install e }
  end

  def caveats
    <<~EOS
      RVV (rv64gcv) CPU provider, no HMS / no LiteTurbo (LLM runtime is closed
      source upstream). Quick checks:
        mslite-verify #{share}/mindspore-lite/models/matmul_tg1.ms \\
                      #{share}/mindspore-lite/models/matmul_tg1.input.bin \\
                      #{share}/mindspore-lite/models/matmul_tg1.output.bin
        benchmark --modelFile=#{share}/mindspore-lite/models/block_qwen_w8.ms \\
                  --loopCount=20 --numThreads=8
      A100 cluster (cpus 8-15): ai-runner --affinity=8-15 -- benchmark ...
      Full bench model set (pp128/tg1/quantized transformer block, ops sized
      like Qwen2.5-0.5B) is release asset bench-models-k3.tar.gz on riscv-bin;
      measured numbers live in share/mindspore-lite/README.md.
    EOS
  end

  test do
    system "#{bin}/mslite-verify", "#{share}/mindspore-lite/models/matmul_tg1.ms",
           "#{share}/mindspore-lite/models/matmul_tg1.input.bin",
           "#{share}/mindspore-lite/models/matmul_tg1.output.bin", "2"
  end
end
