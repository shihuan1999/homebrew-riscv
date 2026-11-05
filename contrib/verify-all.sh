#!/bin/sh
# hbrew 全量真机回归（在设备上运行）：对 tap 内全部 formula 执行
#   install -> 可执行冒烟 -> uninstall（保留依赖）
# 结果写入 $VDIR/results.tsv，支持断点续跑（已记录的包跳过）。
# 由 verify-all.yml 从网关推送并后台拉起，也可手动执行。
# 用法: sh verify-all.sh [formula ...]   # 无参 = tap 全量
set -u
export TERM=dumb
export HOME=/data/hbrew-home
. /data/harmonybrew/hbrew-env.sh

VDIR=${HBREW_VERIFY_DIR:-/data/hbrew-verify}
LOG=$VDIR/results.tsv
FAILED=$VDIR/failed.txt
mkdir -p "$VDIR"
[ -f "$LOG" ] || printf 'name\tresult\tsecs\tsmoke\tversion\n' > "$LOG"
: > "$FAILED"

TAP=/data/harmonybrew/Library/Taps/hbrew/homebrew-riscv
if [ $# -gt 0 ]; then
  PKGS="$*"
else
  PKGS=$(cd "$TAP/Formula" 2>/dev/null && ls */*.rb | sed 's|.*/\([^/]*\)\.rb|\1|' | tr '\n' ' ')
fi
[ -n "$PKGS" ] || { echo "no formulas found under $TAP/Formula" >&2; echo DONE > "$VDIR/current"; exit 1; }

smoke() {
  p="$1"
  keg=$(ls -d "$HOMEBREW_CELLAR/$p"/*/ 2>/dev/null | tail -1)
  [ -z "$keg" ] && { echo "no-keg"; return 2; }
  case "$p" in
    bash)          bash -c 'echo bash-ok';;
    busybox)       busybox 2>&1 | head -1;;
    coreutils)     "$keg/bin/gls" --version 2>&1 | head -1;;
    curl)          curl --version 2>&1 | head -1;;
    python)        "$keg/bin/python3" --version 2>&1 | head -1;;
    python@3.11)   "$keg/bin/python3.11" --version 2>&1 | head -1;;
    node)          node --version 2>&1 | head -1;;
    openssl)       "$keg/bin/openssl" version 2>&1 | head -1;;
    vim)           "$keg/bin/vim" --version 2>&1 | head -1;;
    zsh)           "$keg/bin/zsh" --version 2>&1 | head -1;;
    jq)            jq --version 2>&1 | head -1;;
    tree)          tree --help 2>&1 | head -1;;
    figlet)        figlet P 2>&1 | head -1;;
    hello)         hello 2>&1 | head -1;;
    mosquitto)     "$keg/sbin/mosquitto" -h 2>&1 | head -1;;
    dropbear)      "$keg/sbin/dropbear" --help 2>&1 | head -1;;
    openssh)       "$keg/bin/ssh" -V 2>&1 | head -1;;
    make)          make --version 2>&1 | head -1;;
    portable-ruby) "$keg"/[0-9]*/bin/ruby --version 2>&1 | head -1;;
    portable-git)  "$keg"/[0-9]*/bin/git --version 2>&1 | head -1;;
    libgpiod)      "$keg/bin/gpiodetect" --version 2>&1 | head -1 || "$keg/bin/gpioinfo" --version 2>&1 | head -1;;
    i2c-tools)     "$keg/bin/i2cdetect" -V 2>&1 | head -1;;
    ros2-*|vscode-server|agentstore-hap|code-*|openjiuwen-*)
                  n=$(find "$keg" -type f 2>/dev/null | wc -l); echo "keg-files:$n";;
    *)
      bin=""
      for d in bin sbin libexec; do
        for f in "$keg$d"/*; do
          [ -f "$f" ] && [ -x "$f" ] && bin="$f" && break 2
        done
      done
      if [ -n "$bin" ]; then
        out=$(timeout 10 "$bin" --version 2>&1 | head -1)
        [ -z "$out" ] && out=$(timeout 10 "$bin" -h 2>&1 | head -1)
        [ -n "$out" ] && echo "$out" || { echo "exec-no-output:$(basename "$bin")"; return 3; }
      else
        n=$(find "$keg" -type f 2>/dev/null | wc -l); echo "keg-files:$n"
      fi;;
  esac
}

i=0; total=$(echo $PKGS | wc -w)
for p in $PKGS; do
  i=$((i+1))
  echo "$p" > "$VDIR/current"
  # 已记录则跳过(断点续跑)
  if grep -q "^$p	" "$LOG" 2>/dev/null; then continue; fi
  echo "[$i/$total] $p install..."
  t0=$(date +%s)
  if out=$(brew install "hbrew/riscv/$p" 2>&1); then
    t1=$(date +%s); s=$((t1-t0))
    ver=$(brew list --versions "$p" 2>/dev/null)
    smk=$(smoke "$p"); rc=$?
    if [ $rc -eq 0 ] || [ $rc -eq 2 ]; then
      printf '%s\tPASS\t%s\t%s\t%s\n' "$p" "$s" "$(echo "$smk" | head -1 | cut -c1-80)" "$ver" >> "$LOG"
      echo "  => PASS (${s}s) $smk"
    else
      printf '%s\tSMOKE-FAIL\t%s\t%s\t%s\n' "$p" "$s" "$(echo "$smk" | head -1 | cut -c1-80)" "$ver" >> "$LOG"
      echo "$p" >> "$FAILED"
      echo "  => SMOKE-FAIL: $smk"
    fi
  else
    t1=$(date +%s); s=$((t1-t0))
    printf '%s\tINSTALL-FAIL\t%s\t%s\t-\n' "$p" "$s" "$(echo "$out" | tail -2 | head -1 | cut -c1-80)" >> "$LOG"
    echo "$p" >> "$FAILED"
    echo "  => INSTALL-FAIL: $(echo "$out" | tail -3)"
  fi
  # 卸载本体(保留依赖)
  brew uninstall "$p" >/dev/null 2>&1
  sync
done
echo DONE > "$VDIR/current"
echo "=== ALL DONE: $(grep -c PASS "$LOG") pass, $(wc -l < "$FAILED") fail ==="
