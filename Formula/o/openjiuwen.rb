# openjiuwen: agent-core 0.1.17 + full riscv64-ohos python dependency closure
# Compiled extensions (pydantic-core/rpds/jiter/tiktoken/numpy/Pillow/pycryptodome)
# are cross-built riscv64 musl; everything else is pure python. Base for the
# openjiuwen-* app formulas.
class Openjiuwen < Formula
  desc "openJiuwen agent framework (core 0.1.17) with riscv64-ohos dep closure"
  homepage "https://github.com/openJiuwen-ai/agent-core"
  url "https://files.pythonhosted.org/packages/source/o/openjiuwen/openjiuwen-0.1.17-py3-none-any.whl"
  sha256 "c956efb1c227beff3b3b164f74f68b52a2d22a7699b22de4a92b623255141511"
  version "0.1.17"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/shihuan1999/riscv-bin/releases/download/openjiuwen-v1.0"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "0a3c6b4c386ed0b793bf9b56bf1b9be4d347e34e3140b36a753cfba2055db22e"
  end

  depends_on "hbrew/riscv/python"

  def install
    # Bottle is authoritative (pre-staged site-packages closure for python 3.11).
    prefix.install Dir["*"]
  end

  def caveats
    <<~EOS
      openjiuwen core + riscv64 closure installed under #{libexec}/site-packages.
      Other openjiuwen-* formulas reference it as their python base:
        OJW_BASE=#{libexec}/site-packages
      Quick check:
        #{bin}/openjiuwen
    EOS
  end

  test do
    system "#{bin}/openjiuwen"
  end
end
