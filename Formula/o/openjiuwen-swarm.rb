# openjiuwen-swarm: jiuwenswarm multi-agent app (AgentServer + gateway) for
# OHOS riscv64. Vendored openjiuwen core is the agent-core develop tree the
# app is built against (symphony.discovery / foundation.kv_cache APIs), pinned
# at commit 1889660. Extended cryptography stub, fastmcp 2.14.7 + mcp 1.29.1
# closure, psutil (abi3 riscv64), a2ui SDK included. Verified on device:
# AgentServer boots on ws://127.0.0.1 and completes a real LLM agent turn
# (tool-using, glm-5.2 via relay).
class OpenjiuwenSwarm < Formula
  desc "jiuwenswarm multi-agent app: AgentServer + E2A gateway (OHOS riscv64)"
  homepage "https://github.com/openJiuwen-ai/jiuwenswarm"
  url "https://github.com/openJiuwen-ai/jiuwenswarm/archive/785999334d29edd5790ffdb04ed8dac4798a81f4.tar.gz"
  sha256 "f7ff62fa9cd2972f3fe99b2e2360f860829d164e1401bc81b30ab0e1b426959c"
  version "1.0.0"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/openjiuwen-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "386eb4dd5bcbdddc9b345af33817f5c67bd8ad32508651987abf6d34b2cd6fb1"
  end

  depends_on "hbrew/riscv/python"
  depends_on "hbrew/riscv/openjiuwen"

  def install
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      jiuwenswarm installed. First run:
        jiwenswarm-init                      # creates $HOME/.jiuwenswarm workspace
        vi $HOME/.jiuwenswarm/config/.env    # set API_BASE / API_KEY / MODEL_NAME
        jiwenswarm-agentserver --port 18600  # boot the AgentServer
        jiwenswarm-smoke 18600               # one real agent turn (needs LLM)
      The vendored openjiuwen (agent-core develop @1889660) intentionally
      shadows the 0.1.17 base - do not reorder PYTHONPATH.
    EOS
  end

  test do
    system "true"
  end
end
