# riscv64_ohos bottle — built via builds/mosquitto/build.sh (see CONTRIBUTING.md)
class Mosquitto < Formula

      bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "2669b0e7b30cf3e7da588ed6b54212afafd2b232a238a7ad9e876f4268d8fd13"
  end
  desc "MQTT broker and clients — robot telemetry and control channel"
  homepage "https://mosquitto.org/"
  url "https://mosquitto.org/files/source/mosquitto-2.0.20.tar.gz"
  version "2.0.20"
  sha256 "ebd07d89d2a446a7f74100ad51272e4a8bf300b61634a7812e19f068f2759de8"
  license "EPL-2.0"

  depends_on "hbrew/riscv/cjson"

  def install
    # TLS disabled to keep the keg self-contained (local robot networks);
    # rebuild with WITH_TLS=yes against an openssl keg if needed.
    # OHOS musl omits pthread_cancel/pthread_testcancel — a no-op compat object
    # is linked into libmosquitto so load-time relocations resolve (see
    # builds/mosquitto/build.sh).
    system "make", "WITH_DOCS=no", "WITH_TLS=no", "WITH_WEBSOCKETS=no",
           "WITH_STATIC_LIBS=no", "CC=#{ENV.cc}", "CXX=#{ENV.cxx}",
           "CFLAGS=#{ENV.cflags} -I#{Formula["hbrew/riscv/cjson"].opt_include}",
           "LDFLAGS=ohos_pthread_compat.o -L#{Formula["hbrew/riscv/cjson"].opt_lib} -Wl,-rpath,$ORIGIN/../lib"
    system "make", "DESTDIR=#{File.dirname(prefix.to_s)}", "prefix=#{prefix}",
           "WITH_DOCS=no", "WITH_TLS=no", "WITH_WEBSOCKETS=no", "install"
  end

  def caveats
    <<~EOS
      Broker: sbin/mosquitto   Clients: bin/mosquitto_pub / bin/mosquitto_sub / bin/mosquitto_rr
      Quick test on device:
        mosquitto -d && mosquitto_pub -t demo -m hi && mosquitto_sub -t demo -C 1
    EOS
  end

  test do
    assert_match(/2\.0\.20/, shell_output("#{bin}/mosquitto_pub --help 2>&1", 1))
  end
end
