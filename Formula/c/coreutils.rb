# riscv64_ohos prebuilt dist — ported from Harmonybrew/ohos-*, see build-org-tools.sh
class Coreutils < Formula
  desc "GNU file, shell and text utilities"
  homepage "https://www.gnu.org/software/coreutils/"
  url "https://mirrors.tuna.tsinghua.edu.cn/gnu/coreutils/coreutils-9.11.tar.gz"
  sha256 "2033b8a3049c06bff49a9e3cea72bdf4683bcd0cbeb975211dd56dbaf8b736ae"
  version "9.11"


  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/bottles-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "fe90ee4b7fb69f8cf181cbfda833abccb21608db71664d58243f1f55f05db4dd"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/coreutils-9.11-ohos-riscv64.tar.gz"
    sha256 "26c86585e97008093b988c3682b7ad7d69fd43af02ebf39fab1d62c014db8627"
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
