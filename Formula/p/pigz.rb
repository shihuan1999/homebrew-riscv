class Pigz < Formula
  desc "Parallel gzip compression utility"
  homepage "https://zlib.net/pigz/"
  url "http://www.zlib.net/pigz/pigz-2.8.tar.gz"
  sha256 "7a496b66c67e6e4c1abfb5fc3cf4f8dc7e2c77897b2a23d8fa8b5bf89f1e0ee4"
  version "2.8"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/bottles-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "c260c302766c67bef145246d0e63eba7d1e7e774066dfce0752fcd1106e00fe3"
  end

  depends_on "hbrew/riscv/zlib"

  def install
    prefix.install Dir["*"]
  end

  test do
    system "#{bin}/pigz", "--version"
  end
end
