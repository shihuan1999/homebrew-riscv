# Portable Ruby for riscv64-ohos (Homebrew internal dependency)
class PortableRuby < Formula
  desc "Ruby interpreter (Homebrew portable version)"
  homepage "https://www.ruby-lang.org/"
  url "https://cache.ruby-lang.org/pub/ruby/3.3/ruby-3.3.6.tar.gz"
  sha256 "8dc48fffaf270f86f1019053f28e51e4da4cce32a36760a0603a9aee67d7fd8d"
  version "4.0.3"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/bottles-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "939f8986bd99670ae69dff300071be9473ff23112974c02ae8e3797af91caced"
  end

  depends_on "hbrew/riscv/openssl"
  depends_on "hbrew/riscv/zlib"

  def install
    prefix.install Dir["*"]
  end

  test do
    system "#{bin}/ruby", "-e", "puts RUBY_VERSION"
  end
end
