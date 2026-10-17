# agentstore-hap — Bianbu AgentStore 复刻版 HAP（OpenHarmony riscv64）+ 设备端包装命令。
# 复刻进迭时空 2026-10 开源的 Bianbu AgentOS / Bibit AgentStore（bianbu-agent-runtime /
# bianbu-agent-memory / bianbu-agent-security / agent-power-manager / bibit-agenthub-plugin），
# 以纯 ArkTS 单 HAP 重写：agent.yaml 专家注册表、SKILL.md 技能、L1/L2/L3 记忆、
# DLP/审批/审计哈希链沙箱、APC 兼容能力商店。HAP 已用 OpenHarmony release profile 签名。
class AgentstoreHap < Formula
  desc "Bianbu AgentStore replica (pure-ArkTS HAP) + on-device install/start/selftest wrappers"
  homepage "https://github.com/spacemit-com"
  url "https://github.com/shihuan1999/riscv-bin/raw/agentstore-v1.0/agentstore-v1.0/agentstore-hap-1.0.0.riscv64_ohos.bottle.tar.gz"
  sha256 "82d740fdf0eeba3381ed573f8e19091b3987f1ddfa194ec40aac8b96f9e9fb97"
  version "1.0.0"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "82d740fdf0eeba3381ed573f8e19091b3987f1ddfa194ec40aac8b96f9e9fb97"
  end

  def install
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      AgentStore (com.example.agentstore) — six-tab agent suite for OHOS 6.1 riscv64:
        对话(工具循环/审批卡) 专家(agent.yaml) 技能(SKILL.md) 商店(APC 兼容) 记忆(L1/L2/L3) 设置

      On-device commands installed to bin/:
        agentstore-install      bm install the bundled signed HAP
        agentstore-start        aa start (pass-through: --ps tab N / --ps selftest 1)
        agentstore-selftest     built-in E2E (real LLM ~2-3min, results via hilog SELFTEST)
        agentstore-uninstall    bm uninstall
        agentstore-log          hilog | grep SELFTEST/CHAT

      Real LLM: run agentstore-relay on the PC + `hdc rport tcp:16000 tcp:16000`;
      default provider bibit-relay -> 127.0.0.1:16000/v1. Offline demo: switch to
      the built-in `mock` provider in 设置. Store works fully offline (bundled APC catalog).
    EOS
  end

  test do
    assert (prefix/"share/agentstore/agentstore-signed.hap").exist?
    assert (prefix/"bin/agentstore-install").exist?
  end
end
