# Python 3.11.4 for riscv64-ohos, prebuilt with zlib/openssl/bzip2/xz/sqlite/libffi
class Python < Formula
  desc "Interpreted, interactive, object-oriented programming language"
  homepage "https://www.python.org/"
  url "https://www.python.org/ftp/python/3.11.4/Python-3.11.4.tgz"
  sha256 "2f0e409df2ab57aa9fc4cbddfb976af44e4e55bf6519cc8e5def77e6c7e6e6c9"
  version "3.11.4"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/bottles-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "91bd1639871919ee3084af24c941b45bb49179c13b89327beb98753dcd47ca0e"
  end

  depends_on "hbrew/riscv/openssl"
  depends_on "hbrew/riscv/zlib"

  def install
    # Bottle is already a pre-staged /data/python3 layout
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      Python 3.11.4 installed to #{prefix}
      
      Set environment variables:
        export PYTHONHOME=#{prefix}
        export PATH=#{prefix}/bin:$PATH
      
      Or source the included setup script:
        . #{prefix}/bin/python-env.sh
      
      Includes pip 23.1.2 and site-packages with:
        - requests, certifi, urllib3, idna, charset-normalizer
        - Pillow, pycryptodome, pyyaml, aiofiles
    EOS
  end

  test do
    system "#{bin}/python3.11", "-c", "import sys; assert sys.version_info >= (3, 11)"
  end
end
