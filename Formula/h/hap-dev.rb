# hap-dev — on-device OpenHarmony HAP development toolchain (riscv64 / OHOS 6.1).
#
# Turns a bare K3 pico (or any OHOS riscv64 board) into a self-hosted HAP build
# host: ArkTS compile (hvigor + es2abc), resource packing (restool /
# app_packing_tool), per-bundle profile issuance and signing (hap-sign-tool +
# OpenHarmony test certs), plus a one-shot `hapdev` driver that mirrors
# DevEco's Run button (build → sign → install → launch).
#
# The bottle intentionally carries only scripts + project templates (tens of KB).
# The bulky parts stay on the device and are located through environment
# variables, because they cannot be redistributed or are simply too large:
#
#   HAPDEV_SDK   ~3.6 GB  ArkTS/JS API defs, native sysroot, previewer, toolchains
#   HAPDEV_SIGN  ~72 KB   OpenHarmony.p12 + pem certs  (test keys: NOT public)
#   HAPDEV_WORK  varies   your HAP projects
#
# A stock image does not ship these, so `hap-dev` is useful either (a) on boards
# provisioned by the 0008 on-device HAP effort, or (b) after you copy an SDK tree
# over. `hapdev doctor` reports exactly which piece is missing.
class HapDev < Formula
  desc "On-device OpenHarmony HAP build chain (hvigor/es2abc/sign) for riscv64"
  homepage "https://github.com/shihuan1999/homebrew-riscv"
  url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles/hap-dev-1.1.1.tar.gz"
  sha256 "8c49151320ad885e1d02d4d38f0c5b34640c704075e36969754aa3ea756c7a83"
  version "1.1.1"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/shihuan1999/homebrew-riscv/releases/download/bottles"
    sha256 cellar: :any_skip_relocation, riscv64_ohos: "df584c54c7a932fae26e7c9ea54c237ff500d0272bd3105ab2647f269b8a48f7"
  end

  # 驱动脚本用 node 跑 hvigor 与 profile 生成；node 不在 bottle 里（体积 + 需
  # trapfix 版本），所以这里只声明软依赖：有 node 包时用它的，没有就用设备的。
  depends_on "hbrew/riscv/node" => :recommended

  def install
    libexec.install Dir["libexec/*"]
    templates.install Dir["templates/*"]

    # env.sh 把 brew 前缀与设备既有部署连起来。不写死 /data/hap-dev：
    # 换板子/换路径只改环境变量，脚本本身不动。
    (libexec/"env.sh").write <<~EOS
      # hap-dev environment (source me, or use the hapdev wrapper directly)
      export HAPDEV="${HAPDEV:-#{opt_prefix}}"
      export HAPDEV_SDK="${HAPDEV_SDK:-/data/hap-dev/sdk}"
      export HAPDEV_SIGN="${HAPDEV_SIGN:-/data/hap-dev/sign}"
      export HAPDEV_WORK="${HAPDEV_WORK:-/data/hap-dev/work}"
      export HAPDEV_OUT="${HAPDEV_OUT:-/data/hap-dev/output}"
      export HAPDEV_TEMPLATE="${HAPDEV_TEMPLATE:-#{opt_prefix}/templates}"
      export HAPDEV_NODE="${HAPDEV_NODE:-#{Formula["node"].opt_bin}/node}"
      export HAPDEV_HOOK="${HAPDEV_HOOK:-#{opt_prefix}/libexec/support/hook.js}"
      # NAPI 链接所需的 libace_napi.z.so 由系统提供，构建时按 -L 指到这份拷贝
      export HAPDEV_LIB="${HAPDEV_LIB:-/data/hap-dev/lib}"
      export PATH="#{opt_bin}:$PATH"
    EOS

    # hapdev 需要以 keg 自己的 libexec 为根，同时保留用户可覆盖的环境变量。
    # 直接把 env.sh source 进来最省事，也保证两处默认值不会漂移。
    (bin/"hapdev").write <<~EOS
      #!/system/bin/sh
      . "#{libexec}/env.sh"
      exec "/system/bin/sh" "#{libexec}/bin/hapdev" "$@"
    EOS
    chmod 0755, bin/"hapdev"

    (bin/"hapdart-profile").write <<~EOS
      #!/system/bin/sh
      # 为任意 bundleName 生成 profile JSON（再交给 hap-sign-tool sign-profile）
      . "#{libexec}/env.sh"
      exec "$HAPDEV_NODE" "#{libexec}/bin/gen-profile.js" "$@"
    EOS
    chmod 0755, bin/"hapdart-profile"
  end

  def caveats
    <<~EOS
      hap-dev installed. Two quick checks:

        hapdev doctor            # 逐项报告 SDK / 签名材料 / node 是否齐备
        hapdev new demo && hapdev run demo

      Payloads it expects (override with the same-named env var):

        HAPDEV_SDK       default /data/hap-dev/sdk
                         needs <sdk>/oh-sdk/23/{ets,js,native,previewer,toolchains}
        HAPDEV_SIGN      default /data/hap-dev/sign
                         needs OpenHarmony.p12, OpenHarmonyApplication.pem,
                         OpenHarmonyProfileRelease.pem, hapdemo_profile.json
        HAPDEV_WORK      default /data/hap-dev/work   (your projects)

      Signing is per-bundle and automatic: `hapdev build` regenerates the profile
      JSON from the project's module.json5 permissions and issues
      <sign>/<bundle>-release.p7b, so `hapdev new anything && hapdev run anything`
      installs under its own bundle name. Note the two distinct key aliases in
      OpenHarmony.p12 — sign-profile needs
      "openharmony application profile release" while sign-app needs
      "openharmony application release"; mixing them fails with
      "keyAlias private key matches the public key in the certificate".

      The bundled template is a device-control demo (deviceInfo / keep-screen-on /
      vibrator) — a working reference for real system API calls, not a mock.
    EOS
  end

  test do
    assert_predicate bin/"hapdev", :exist?
    assert_predicate bin/"hapdart-profile", :exist?
    assert_predicate libexec/"bin/gen-profile.js", :exist?
    assert_predicate prefix/"templates/entry/src/main/ets/pages/Index.ets", :exist?
    system bin/"hapdev", "version"
  end
end
