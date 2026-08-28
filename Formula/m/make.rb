# riscv64_ohos prebuilt dist — ported from Harmonybrew/ohos-*, see build-org-tools.sh
class Make < Formula
  desc "GNU make utility to build projects"
  homepage "https://www.gnu.org/software/make/"
  url "https://mirrors.tuna.tsinghua.edu.cn/gnu/make/make-4.4.1.tar.gz"
  sha256 "dd16fb1d67bfab79a72f5e8390735c49e3e8e70b4945a15ab1f81ddb78658fb3"
  version "4.4.1"


  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/bottles-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "69246b6f05c48c725210f2b178f5540084e05415eeec516f237ad28ad37228a1"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/make-4.4.1-ohos-riscv64.tar.gz"
    sha256 "63efd3f85fe97ecb9f2c1ff918dd96d426c43bbc1327caa9eac588c86feb6578"
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
