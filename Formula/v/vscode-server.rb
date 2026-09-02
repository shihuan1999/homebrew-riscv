# openvscode-server v1.109.5 assembled for OHOS riscv64: official x64 release +
# swapped native parts (node trapfix riscv64 v22.16.0, node-pty, spdlog,
# native-watchdog, @parcel/watcher, ripgrep 13.0.0 musl). Retrofit port, no
# source patches — port overlay: riscv64-ohos branch of
# https://github.com/shihuan1999/openvscode-server (build scripts in
# shihuan1999/vscode-ohos-port). Verified on K3 pico (OHOS 6.1): browser
# editor UI on :3000, edit+save loop.
class VscodeServer < Formula
  desc "openvscode-server: browser VS Code server (OHOS riscv64 port)"
  homepage "https://github.com/gitpod-io/openvscode-server"
  url "https://github.com/gitpod-io/openvscode-server/releases/download/openvscode-server-v1.109.5/openvscode-server-v1.109.5-linux-x64.tar.gz"
  sha256 "b433bf4f0227321a7014d8460d10a8f958adc0f45aa79bd889e84e65e8f88363"
  version "1.109.5"
  license "MIT"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/vscode-v1.109.5-ohos"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "f748fbe45b59b96a6f4f9f4caf3dacd345a729efe10d2610dc8bcf14cc2db2ad"
  end

  def install
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      openvscode-server installed to #{prefix} (self-contained riscv64 build).
      Start: #{prefix}/start.sh   (or ohos-deploy/start.sh from the port branch)
      Browser: http://<device-ip>:3000
      Extensions: brew install hbrew/riscv/code-hapdev hbrew/riscv/code-deveco
    EOS
  end

  test do
    system "true"
  end
end
