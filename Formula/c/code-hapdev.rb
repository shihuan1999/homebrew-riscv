# ohos-dev VS Code extension (hap-dev: on-device HAP build assistant) for the
# OHOS riscv64 vscode-server. Pure-vsix package (installed from source; no
# bottle needed). Installer unzips into ~/.openvscode-server/extensions/
# <publisher>.<name>-<ver> and merges extensions.json (publisher-prefixed dir
# name is mandatory — see ohos-devsuite notes).
class CodeHapdev < Formula
  desc "ohos-dev VS Code extension (hap-dev) + installer (OHOS riscv64)"
  homepage "https://github.com/shihuan1999/vscode-ohos-port"
  url "https://github.com/shihuan1999/riscv-bin/releases/download/vscode-v1.109.5-ohos/ohos-dev-0.1.0.vsix"
  sha256 "0acd796210d3b7d1d5589dd42e0de5e51478d7d8140b67d72e246ffa1cc2a196"
  version "0.1.0"
  license "MIT"

  depends_on "hbrew/riscv/vscode-server"

  def install
    (share/"vsix").install "ohos-dev-0.1.0.vsix"
    installer = <<~EOS
      #!/bin/sh
      # register ohos-dev extension into the device vscode-server
      set -e
      VSIX="#{prefix}/share/vsix/ohos-dev-0.1.0.vsix"
      VSHOME="${VSCODE_HOME:-/data/vscode/home}"
      EXTDIR="$VSHOME/.openvscode-server/extensions"
      ID="riscv-ohos.ohos-dev"; VER="0.1.0"; DIR="$EXTDIR/$ID-$VER"
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
    (bin/"code-hapdev-install").write installer
    chmod 0755, bin/"code-hapdev-install"
  end

  def caveats
    <<~EOS
      Register the extension: code-hapdev-install
      (VSCODE_HOME defaults to /data/vscode/home)
    EOS
  end

  test do
    system "true"
  end
end
