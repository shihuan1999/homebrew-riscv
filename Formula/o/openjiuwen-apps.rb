# openjiuwen-apps: the on-device openJiuwen agent suite from the OHOS port -
# sidecar server (:8765) with deepresearch / career / diag / perf / kb agents,
# local knowledge base (kb_store + kb_local_search custom engine + corpus),
# agent-memory repo and the kbapp HAP source tree. DeepSearch pinned to the
# dev branch (193f7c9) layout; openjiuwen core pinned 0.1.17 like the base.
class OpenjiuwenApps < Formula
  desc "openJiuwen on-device agents: deepsearch/career/diag/perf/kb sidecar + KB"
  homepage "https://github.com/openJiuwen-ai/deepsearch"
  url "https://github.com/openJiuwen-ai/deepsearch/archive/dev.tar.gz"
  sha256 "50feffb1b519a96cd2fb8b80156d04707c2fa47b31d813e55d3e8f0feddc155b"
  version "1.0.0"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/openjiuwen-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "2e8a16a72ad6712ff6e7cce3f1a7e0e5bfbc8dea4347a4b8779d00420ea2c738"
  end

  depends_on "hbrew/riscv/python"
  depends_on "hbrew/riscv/openjiuwen"

  def install
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      On-device agent suite installed under #{libexec}/agents.
      Start the sidecar (LLM env vars in agents/*.py):
        openjiuwen-agents
      Includes: openjiuwen_deepsearch + kb_local_search (local KB engine,
      no external search API), career_sim_runner, agent-memory, kbapp HAP
      source, kb corpus data. Uses the openjiuwen base closure (0.1.17).
    EOS
  end

  test do
    system "test", "-f", "#{libexec}/agents/agent_server.py"
  end
end
