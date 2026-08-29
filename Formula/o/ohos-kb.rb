# ohos-kb: zero-dependency local knowledge base (ingest / search / RAG QA / eval)
# Pure Python stdlib; runs on riscv64-ohos with brew python 3.11.
class OhosKb < Formula
  desc "Zero-dep local knowledge base: file ingest, hybrid search, RAG QA, standard eval"
  homepage "https://github.com/shihuan1999/ohos-kb"
  url "https://github.com/shihuan1999/ohos-kb/releases/download/v1.0.0/ohos-kb-1.0.0.tar.gz"
  sha256 "3ed2881b46250405b4366e3c8ab90e9ff0bd4853faa207b25091d43445e86f11"
  version "1.0.0"
  license "MIT"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/bottles-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "3bf8f34677e686ec25bc974e4cdecabcb02d26ee37966fd76520385db10c039b"
  end

  # Intranet mirror (snode7 bottle server) for offline/source installs
  resource "mirror" do
    url "http://10.0.50.17:8090/dist/ohos-kb-1.0.0.tar.gz"
    sha256 "3ed2881b46250405b4366e3c8ab90e9ff0bd4853faa207b25091d43445e86f11"
  end

  depends_on "hbrew/riscv/python"

  def install
    # kb/*.py -> libexec 平铺（cli.py 的 flat 导入模式），eval_data 随包自测/测评
    libexec.install Dir["kb/*.py"]
    libexec.install "eval_data"
    (bin/"ohos-kb").write <<~EOS
      #!/bin/sh
      export LD_LIBRARY_PATH="#{Formula["python"].lib}:$LD_LIBRARY_PATH"
      export KB_HOME="${KB_HOME:-$HOME/.ohos-kb}"
      exec #{Formula["python"].opt_bin}/python3.11 #{libexec}/cli.py "$@"
    EOS
  end

  def caveats
    <<~EOS
      ohos-kb installed. Try:
        ohos-kb ingest #{libexec}/eval_data/corpus
        ohos-kb search "AI 算力"
        ohos-kb ask "K3 Pico-ITX 的 AI 算力是多少？" --no-llm
        ohos-kb eval #{libexec}/eval_data/kb_qa.jsonl --out /tmp/eval_out
        ohos-kb serve --port 8900
      Data dir: $KB_HOME (default $HOME/.ohos-kb); LLM via LLM_BASE/LLM_KEY/LLM_MODEL.
      Also live in the openJiuwen sidecar (:8765, /api/kb/upload|ask|eval).
  EOS
  end

  test do
    system "#{bin}/ohos-kb", "stats"
  end
end
