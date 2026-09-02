# deveco-code (opencode SDK 1.17.9) VS Code extension for the OHOS riscv64
# vscode-server. Built with bun+vsce from deveco-code sdks/vscode (icon/png
# fixes recorded in shihuan1999/deveco-ohos-port). Thin terminal-launcher that
# pairs with the deveco CLI on device.
class CodeDeveco < Formula
  desc "deveco-code (opencode) VS Code extension + installer (OHOS riscv64)"
  homepage "https://github.com/shihuan1999/deveco-ohos-port"
  url "https://github.com/shihuan1999/riscv-bin/releases/download/vscode-v1.109.5-ohos/deveco-code-1.17.9.vsix"
  sha256 "c1bef46c6c98dde4169e47ef6eb286269a6cfb66ed38d8984258630f8a3d2ea6"
  version "1.17.9"
  license "MIT"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/vscode-v1.109.5-ohos"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "05df93994e295471c1d6ceda73a180f810dd8abee30097682d8ed4bdb6d7f738"
  end

  depends_on "hbrew/riscv/vscode-server"

  def install
    (share/"vsix").install "deveco-code-1.17.9.vsix"
    installer = <<~EOS
      #!/bin/sh
      # register deveco-code extension into the device vscode-server
      set -e
      VSIX="#{prefix}/share/vsix/deveco-code-1.17.9.vsix"
      VSHOME="${VSCODE_HOME:-/data/vscode/home}"
      EXTDIR="$VSHOME/.openvscode-server/extensions"
      ID="sst-dev.opencode"; VER="1.17.9"; DIR="$EXTDIR/$ID-$VER"
      mkdir -p "$DIR"; cd "$DIR"
      PY="$(command -v python3.12 || command -v python3)"
      "$PY" - "$VSIX" <<'PY'
import zipfile, sys
zipfile.ZipFile(sys.argv[1]).extractall("_x")
PY
      cp -r _x/extension/. . && rm -rf _x
      "$PY" - "$EXTDIR/extensions.json" "$ID" "$VER" "$DIR" <<'PY'
import json, sys, os
p, i, v, d = sys.argv[1:5]
ents = []
if os.path.exists(p):
    try: ents = json.load(open(p))
    except Exception: ents = []
if not any(e.get("identifier",{}).get("id")==i and e.get("version")==v for e in ents):
    ents.append({"identifier":{"id":i},"version":v,
                 "location":{"$mid":1,"path":d,"scheme":"file"},
                 "relativeLocation":os.path.basename(d)})
json.dump(ents, open(p,"w")); print("installed", i, v)
PY
    EOS
    (bin/"code-deveco-install").write installer
    chmod 0755, bin/"code-deveco-install"
  end

  def caveats
    <<~EOS
      Register the extension: code-deveco-install
      Terminal launcher pairs with the deveco CLI (deveco-ohos-port).
    EOS
  end

  test do
    system "true"
  end
end
