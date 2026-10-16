# agentstore-relay — OpenAI-compatible LLM relay for the AgentStore HAP.
# Forwards device requests (127.0.0.1:16000 over `hdc rport`) to the upstream
# endpoint and injects the API key, so the key never lands on the device.
# Pure stdlib python; the API key is supplied via RELAY_API_KEY and is NOT bundled.
class AgentstoreRelay < Formula
  desc "OpenAI-compatible LLM relay for AgentStore HAP (key stays on host, hdc rport tunnel)"
  homepage "https://github.com/spacemit-com"
  url "https://github.com/shihuan1999/riscv-bin/raw/agentstore-v1.0/agentstore-v1.0/agentstore-relay-1.0.0.riscv64_ohos.bottle.tar.gz"
  sha256 "20d9fd9db1190ff193d7e076b00f82aaa14f9869b1194a0436e6362f11a5ee02"
  version "1.0.0"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/raw/agentstore-v1.0/agentstore-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "20d9fd9db1190ff193d7e076b00f82aaa14f9869b1194a0436e6362f11a5ee02"
  end

  depends_on "hbrew/riscv/python"

  def install
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      Run on the PC (or any host with python3 + outbound net):
        export RELAY_API_KEY=sk-xxx          # key stays on this host
        agentstore-relay                     # listens on 127.0.0.1:16000
        hdc rport tcp:16000 tcp:16000        # expose to the device

      Device side: AgentStore HAP default provider bibit-relay -> 127.0.0.1:16000/v1.
      Override upstream/port via RELAY_UPSTREAM / RELAY_PORT.
    EOS
  end

  test do
    assert (prefix/"libexec/llm_relay.py").exist?
    assert (prefix/"bin/agentstore-relay").exist?
  end
end
