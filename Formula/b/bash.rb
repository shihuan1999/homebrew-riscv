# riscv64_ohos prebuilt dist — ported from Harmonybrew/ohos-*, see build-org-tools.sh
class Bash < Formula
  desc "Bourne-Again SHell"
  homepage "https://www.gnu.org/software/bash/"
  url "https://mirrors.tuna.tsinghua.edu.cn/gnu/bash/bash-5.3.tar.gz"
  sha256 "0d5cd86965f869a26cf64f4b71be7b96f90a3ba8b3d74e27e8e9d9d5550f31ba"
  version "5.3"

  depends_on "ncurses"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/bottles-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "7a7b9469700d161008d8aa3ecae4a745a9f958d2e384c92d5f80801a9de8e98e"
  end

  resource "ohos_riscv64_dist" do
    url "http://10.0.50.17:8090/dist/bash-5.3-ohos-riscv64.tar.gz"
    sha256 "14dae47d850e48cc30372a301a1ec733ca41820e10fce0f016c575993f94b7d0"
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
