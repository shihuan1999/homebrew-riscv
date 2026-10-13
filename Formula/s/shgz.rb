# 由 brewpack 于 2026-10-13 19:10:06 从设备本地项目生成 — Harmonybrew(riscv64_ohos) 设备端打包
class Shgz < Formula
  desc "Demo shell tool depending on hbrew/riscv/pigz"
  homepage "https://github.com/shihuan1999/homebrew-riscv"
  url "https://github.com/shihuan1999/homebrew-riscv/releases/download/brewpack/shgz-0.1.0.riscv64_ohos.bottle.tar.gz"
  sha256 "affd821b06ef55567fe9e58aa3c0df77b59d73c89a9e8226829cdd56626ed85f"
  version "0.1.0"

  bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/brewpack"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "affd821b06ef55567fe9e58aa3c0df77b59d73c89a9e8226829cdd56626ed85f"
  end

  depends_on "hbrew/riscv/pigz"

  def install
    prefix.install Dir["*"]
  end

  test do
    system "true" # 真实验收由 brewpack test 执行
  end
end
