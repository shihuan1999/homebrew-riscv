# Python 3.11.4 for riscv64-ohos (musl) — legacy 3.11 line, kept for
# compatibility with scripts pinned to 3.11. New code should use `python` (3.12).
class PythonAT311 < Formula

      bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "8abf158a1bfa9436da4cba301bbb19a3d1c1908d7f04ef6eb8d4471386d5afb3"
  end
  desc "Interpreted, interactive, object-oriented programming language (3.11 line)"
  homepage "https://www.python.org/"
  url "https://www.python.org/ftp/python/3.11.4/Python-3.11.4.tgz"
  sha256 "2f0e409df2ab57aa9fc4cbddfb976af44e4e55bf6519cc8e5def77e6c7e6e6c9"
  version "3.11.4"
  keg_only :versioned_formula

  def install
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      Python 3.11.4 (musl riscv64) at #{prefix}

      Load environment:
        . #{prefix}/bin/python-env.sh #{prefix}

      First run installs pip via:  python3.11 -m ensurepip

      Offline devices: pre-staging the brew download cache does not work for
      @-versioned names — extract the bottle into Cellar/ and create the opt
      symlink manually (see CONTRIBUTING.md 离线设备安装).
    EOS
  end

  test do
    system "#{bin}/python3.11", "-c", "import sys; assert sys.version_info >= (3, 11)"
  end
end
