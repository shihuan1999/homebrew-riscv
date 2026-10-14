# Python 3.12.14 for riscv64-ohos (musl), self-contained keg:
# bundles zlib/openssl/bzip2/xz/sqlite/libffi/ncurses/readline/expat +
# __riscv_flush_icache shim + multi-source pip.conf (see builds/python/).
class Python < Formula

      bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "a01fcc30c66221cc979b6047b1fd0581d5bd13c710d8fd7444cecb1368050d0f"
  end
  desc "Interpreted, interactive, object-oriented programming language"
  homepage "https://www.python.org/"
  url "https://www.python.org/ftp/python/3.12.14/Python-3.12.14.tgz"
  sha256 "6c6df908d2c3fd24e6d76869e92542abd0f33aec9dfc18df8875f89660286d43"
  version "3.12.14"

  def install
    # Bottle is a fully pre-staged keg (bin/lib/etc/share) — see builds/python/build.sh
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      Python 3.12.14 (musl riscv64) at #{prefix}

      Load environment (PATH/PYTHONHOME/LD_PRELOAD shim/pip multi-source):
        . #{prefix}/bin/python-env.sh        # bash
        . #{prefix}/bin/python-env.sh #{prefix}   # plain sh

      First run installs pip via:  python3.12 -m ensurepip

      pip sources (etc/pip.conf): TUNA PyPI mirror (primary) + Aliyun mirror
      + harmonybrew riscv64 musl wheel index:
        https://shihuan1999.github.io/homebrew-riscv/wheels/simple/

      Do NOT add glibc-oriented riscv64 wheel indexes (e.g. gounthar's) —
      their linux_riscv64 wheels match by tag but link glibc and will fail.
    EOS
  end

  test do
    system "#{bin}/python3.12", "-c", "import sys; assert sys.version_info >= (3, 12)"
  end
end
