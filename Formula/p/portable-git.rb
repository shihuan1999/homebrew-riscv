# Portable Git for riscv64-ohos (self-contained with minimal dependencies)
class PortableGit < Formula
  desc "Distributed version control system"
  homepage "https://git-scm.com"
  url "https://www.kernel.org/pub/software/scm/git/git-2.54.0.tar.gz"
  sha256 "3c6e3a1eb0fe0e4c0f989eb77e2ade8c5e3be81b49b1f25e8c79cce65b40d22d"
  version "2.54.0"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/bottles-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "33a1990d37bde7bbe07bec255a304400d6df64ff87f6d378007d5aaa60860d93"
  end

  depends_on "hbrew/riscv/curl"
  depends_on "hbrew/riscv/openssl"
  depends_on "hbrew/riscv/zlib"

  def install
    prefix.install Dir["*"]
  end

  test do
    system "#{bin}/git", "--version"
  end
end
