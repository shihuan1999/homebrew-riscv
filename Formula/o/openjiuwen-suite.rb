# openjiuwen-suite: meta formula - everything from the openJiuwen OHOS riscv64
# port in one `brew install openjiuwen-suite`.
class OpenjiuwenSuite < Formula
  desc "Meta package: openJiuwen framework + agents + symbiosis + swarm (OHOS riscv64)"
  homepage "https://github.com/shihuan1999/riscv-bin"
  url "https://github.com/openJiuwen-ai/agent-core/archive/188966006844748d0d8c7d51c619153dd22eebc5.tar.gz"
  sha256 "52622d97cece6f21f6ddfc350ef93b9b2c57bfe59082ffd2b407c9e544853a90"
  version "1.0.0"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/openjiuwen-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "1c378efa1916ec78b0bad272aaf8950ea8d35753f488a76d646b964b96c9cf33"
  end

  depends_on "hbrew/riscv/openjiuwen"
  depends_on "hbrew/riscv/openjiuwen-apps"
  depends_on "hbrew/riscv/openjiuwen-symbiosis"
  depends_on "hbrew/riscv/openjiuwen-swarm"

  def install
    (prefix/"README").write <<~EOS
      openjiuwen-suite pulls in:
        openjiuwen            core 0.1.17 + riscv64 python closure
        openjiuwen-apps       deepsearch/career/diag/perf/kb sidecar
        openjiuwen-symbiosis  robotics framework + scipy shim
        openjiuwen-swarm      AgentServer + E2A gateway
      Quick starts:
        openjiuwen                          # core check
        jiwensymbiosis-demo                 # robotics mock acceptance
        jiwenswarm-init && jiwenswarm-agentserver --port 18600
        openjiuwen-agents                   # sidecar on :8765
    EOS
  end

  def test
    system "test", "-f", "#{prefix}/README"
  end
end
