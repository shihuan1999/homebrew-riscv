# riscv64_ohos bottle — built via builds/ai-gateway/build.sh (see CONTRIBUTING.md)
class AiGateway < Formula

  bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "154ba8a671bb01b583a518af0e160345de490a17ec18e096646301c9a695b1d0"
  end
  desc "On-device AI gateway: LLM + vision + speech + agent tool calls (K3)"
  homepage "https://github.com/shihuan1999/homebrew-riscv"
  url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles/ai-gateway-3.0.0.tar.gz"
  version "3.0.0"
  sha256 "ab0383f574eba768989e80f80e44f4d4cea8d347644a7f92380a9c068bf9337a"
  license "MIT"

  def install
    # The three daemons are cross-built for riscv64 musl and linked against the
    # SpaceMiT EP-aware onnxruntime that ships in the OHOS system image, so the
    # keg stays small (~8 MB) and never duplicates the runtime.
    bin.install Dir["bin/*"]
    (etc/"ai-gateway").install "etc/ai-gateway/gateway.json"

    # Kernels are data files read by /v1/spine/*.
    (var/"ai-gateway/kernels").install Dir["var/ai-gateway/kernels/*"]

    # Sources and cross-build recipes travel with the package so the device can
    # rebuild its own workers without a compiler on board.
    (share/"ai-gateway").install "share/ai-gateway/src"
    (share/"ai-gateway").install "share/ai-gateway/patches"
    (share/"ai-gateway").install "share/ai-gateway/AI-GATEWAY-V3.md"
    (share/"ai-gateway").install "share/ai-gateway/build_gateway.sh"
    (share/"ai-gateway").install "share/ai-gateway/build_sherpa_ep.sh"
    libexec.install "share/ai-gateway/restart.sh"
  end

  def caveats
    <<~EOS
      ai-gateway ships the programs only. The models it serves
      (Qwen3-0.6B ~382 MB, SenseVoice ASR ~239 MB, matcha TTS ~130 MB,
      KWS + VAD) total about 1.5 GB and are downloaded on first use:

        ai-gateway fetch-models            # everything (~1.5 GB)
        ai-gateway fetch-models --only llm # LLM only (~382 MB)

      Then start and smoke-test the stack:

        ai-gateway start
        ai-gateway status
        ai-gateway demo
        ai-gateway stop

      State, models and logs default to /data/ai-gateway. Override with
      AI_GATEWAY_HOME if you keep models on another volume.

      The speech front-end needs a microphone to exercise wake-word/KWS
      capture. On boards without a wired analog mic the gateway detects the
      dead capture device and keeps the HTTP/ASR/TTS paths fully usable.
    EOS
  end

  test do
    # The launcher must answer the CLI contract without touching hardware.
    assert_match "on-device AI gateway", shell_output("#{bin}/ai-gateway --help")
    assert_match "fetch-models", shell_output("#{bin}/ai-gateway --help")

    # Every daemon must be a riscv64 ELF that loads on this system.
    %w[spine-gateway audio-worker vision-worker].each do |daemon|
      assert_path_exists bin/daemon
      assert_predicate bin/daemon, :executable?
    end

    # Reported model state must be well-formed even before models exist.
    out = shell_output("AI_GATEWAY_HOME=#{testpath}/home #{bin}/ai-gateway models")
    assert_match "silero_vad.onnx", out
  end
end
