class Xz < Formula
  desc "General-purpose data compression with high compression ratio"
  homepage "https://tukaani.org/xz/"
  url "https://tukaani.org/xz/xz-5.4.5.tar.gz"
  sha256 "8ccf5fff868c006f29522e386fb4c6a1b66463fbca65a4cfc3c4bd596e895e79"
  version "5.4.5"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/bottles-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "9602915e9a99963097cbf3aeac9caccc2fd326fe749c0ed8998f44112a464450"
  end

  def install
    prefix.install Dir["*"]
  end

  test do
    system "#{bin}/xz", "--version"
  end
end
