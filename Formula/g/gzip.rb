# riscv64_ohos prebuilt dist — ported from Harmonybrew/ohos-*, see build-org-tools.sh
class Gzip < Formula
  desc "GNU compression utility (deflate)"
  homepage "https://www.gnu.org/software/gzip/"
  url "https://mirrors.tuna.tsinghua.edu.cn/gnu/gzip/gzip-1.14.tar.gz"
  sha256 "613d6ea44f1248d7370c7ccdeee0dd0017a09e6c39de894b3c6f03f981191c6b"
  version "1.14"


  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/bottles-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "4192f52b0e613df09e5db12a9b4bd8cb4ccd71f228e04fec3a2761a5035d6e96"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/gzip-1.14-ohos-riscv64.tar.gz"
    sha256 "533e80f7e2d13840d136e6428b5a4e58fd2ab2bef810902afdd7ed0c4ce8a642"
  end

  def install
    resource("ohos_riscv64_dist").stage do
      prefix.install Dir["*"]
    end
  end

  test do
    system "true"
  end
end
