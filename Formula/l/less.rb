# riscv64_ohos prebuilt dist — see harmonybrew-port/build-tools.sh
class Less < Formula
  desc "Pager program similar to more"
  homepage "https://www.gnu.org/software/less/"
  url "https://ftp.gnu.org/gnu/less/less-704.tar.gz"
  sha256 "20a0b0a2bb2525fa53c7eee9beb854b4c9cf172eabb209af7020743547bfe9fb"
  version "704"


  bottle do
    root_url "http://10.0.50.17:8090/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "b067b400b8abdbee43954e1b277e1fc2801ab88e317d43532c3bc66f97c5d3ac"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/less-704-ohos-riscv64.tar.gz"
    sha256 "9ca1807a7a31eabd8e15bf52dc0057192106bcf2a0641a4cc26e63b655f80c5d"
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
