# python (riscv64 musl, OHOS) environment loader
# Usage:
#   bash: . <keg>/bin/python-env.sh
#   sh/dash/toybox: . <keg>/bin/python-env.sh <keg-dir>
# or rely on brew default prefix /data/harmonybrew
if [ -n "${BASH_SOURCE:-}" ]; then
  _py_home=$(cd "$(dirname "$BASH_SOURCE")/.." && pwd)
elif [ -n "$1" ] && [ -x "$1/bin/python3" ]; then
  _py_home="$1"
elif [ -x /data/harmonybrew/opt/python/bin/python3 ]; then
  _py_home=/data/harmonybrew/opt/python
else
  echo "python-env.sh: pass keg dir as \$1" >&2
  return 1 2>/dev/null || exit 1
fi
unset PYTHONHOME PYTHONPATH
export PYTHONHOME="$_py_home"
export PATH="$_py_home/bin:$PATH"
export LD_LIBRARY_PATH="$_py_home/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
# libffi/ctypes need __riscv_flush_icache which musl does not export
export LD_PRELOAD="$_py_home/lib/libriscvflush.so${LD_PRELOAD:+ $LD_PRELOAD}"
[ -f "$_py_home/etc/pip.conf" ] && export PIP_CONFIG_FILE="$_py_home/etc/pip.conf"
[ -d /data/tmp ] || mkdir -p /data/tmp 2>/dev/null
export TMPDIR=/data/tmp
[ -f /etc/ssl/certs/cacert.pem ] && export SSL_CERT_FILE=/etc/ssl/certs/cacert.pem
export TERM=${TERM:-xterm}
unset _py_home
