# deveco — DevEco Code CLI (opencode-based coding agent) for OHOS riscv64.
#
# The device-side CLI of the DevEco Code port: an agentic coding harness that
# reads/edits files, runs commands and drives the on-device HAP toolchain. It is
# the "AI writes the app" half of the on-device story that `hap-dev` completes.
#
# Port notes (see shihuan1999/deveco-ohos-port):
#   · needs a riscv64 node with the V8 wasm trap-handler disabled — the stock
#     node reserves 10 GB guard regions per wasm instance and riscv64 SV39 only
#     has 256 GB of user VA, so the bundled llhttp/tree-sitter wasm exhausts it.
#     This formula depends on `node`, which is exactly that trapfix build.
#   · `deveco` must run with a writable HOME and a stdin that is not a TTY
#     (the run loop hangs otherwise); the wrapper sets both.
#
# The 41 MB JS bundle is a separate payload (app/deveco.mjs) rather than being
# inlined here, because it is regenerated on every upstream release and must not
# bloat the bottle.
class Deveco < Formula
  desc "DevEco Code CLI: agentic coding harness for OHOS riscv64 (on-device)"
  homepage "https://github.com/shihuan1999/deveco-ohos-port"
  url "https://github.com/shihuan1999/deveco-ohos-port/releases/download/v1.0.0/deveco-cli-1.0.0.tar.gz"
  sha256 "265bcb67bb1b0f2f930b9c1df5e8b5a953717adc425f7b39c7a172fc1c4cf447"
  version "1.0.0"
  license "MIT"

  bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "70247fdd269fb32b73079505c2716512d0c90a5a87ce167374538c884e658af0"
  end

  depends_on "hbrew/riscv/node"

  def install
    libexec.install Dir["app"]
    (bin/"deveco").write <<~EOS
      #!/system/bin/sh
      # DevEco Code CLI 启动器。
      # HOME 必须可写（配置在 $HOME/.config/deveco/deveco.json）；
      # stdin 给 /dev/null，否则 run 循环在无 TTY 下会挂住。
      DIR="#{libexec}"
      export HOME="${DEVECO_HOME:-/data/deveco/home}"
      export TMPDIR="${TMPDIR:-$HOME/tmp}"
      mkdir -p "$HOME" "$TMPDIR" 2>/dev/null
      export PATH="#{Formula["node"].opt_bin}:$PATH"
      exec "#{Formula["node"].opt_bin}/node" "$DIR/app/deveco.mjs" "$@" < /dev/null
    EOS
    chmod 0755, bin/"deveco"

    # 配置模板：默认指向本机 relay。真用时要填自己的 baseURL/apiKey。
    (libexec/"deveco.json.example").write <<~EOS
      {
        "provider": {
          "relay": {
            "npm": "@ai-sdk/openai-compatible",
            "name": "Relay Provider",
            "options": { "baseURL": "http://127.0.0.1:8787/v1", "apiKey": "relay-key" },
            "models": { "relay-1": { "name": "Relay Model 1" } }
          }
        },
        "model": "relay/relay-1"
      }
    EOS
  end

  def caveats
    <<~EOS
      deveco CLI installed. It needs an LLM endpoint and a HOME with config:

        mkdir -p "${DEVECO_HOME:-/data/deveco/home}/.config/deveco"
        cp #{libexec}/deveco.json.example \\
           "${DEVECO_HOME:-/data/deveco/home}/.config/deveco/deveco.json"
        # then edit baseURL / apiKey / models

      Quick check (no model needed):
        deveco --version

      The agent drives the same toolchain `hap-dev` installs, so for the full
      on-device loop you want both:

        brew install hbrew/riscv/hap-dev hbrew/riscv/deveco
        hapdev new myapp && hapdev run myapp      # deterministic path
        deveco run 'add a button to myapp'         # agentic path

      Note: the device screenshots/LLM calls need network for a cloud provider;
      for a fully offline device point baseURL at a local llama-server
      (/system/bin/llama-server on stock K3 images, OpenAI-compatible).
    EOS
  end

  test do
    assert_predicate bin/"deveco", :exist?
    assert_predicate libexec/"app/deveco.mjs", :exist?
  end
end
