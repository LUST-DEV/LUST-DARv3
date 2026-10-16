#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
pass() { printf 'PASS: %s\n' "$*"; }

bash "$ROOT/lust-dar" --help >"$TMP/help" || fail 'help returns nonzero'
grep -q -- '--help' "$TMP/help" || fail 'help text missing'; pass 'help'
version="$(bash "$ROOT/lust-dar" --version)"
[[ $version == 'LUST-DAR 5.0.0-dev' ]] || fail "unexpected version: $version"; pass 'version'
(cd /tmp && bash "$ROOT/lust-dar" doctor >"$TMP/doctor") || fail 'doctor failed on host'
grep -q 'Prérequis essentiels présents' "$TMP/doctor" || fail 'doctor result missing'; pass 'doctor from another directory'
(cd /tmp && bash "$ROOT/lust-dar" system >"$TMP/system") || fail 'system command failed'
grep -q 'INFORMATIONS SYSTÈME' "$TMP/system" || fail 'system output missing'; pass 'system from another directory'

printf 'payload\n' >"$TMP/file with spaces.txt"
expected="$(sha256sum "$TMP/file with spaces.txt" | awk '{print $1}')"
out="$(bash "$ROOT/lust-dar" hash "$TMP/file with spaces.txt")" || fail 'hash command failed'
grep -q "$expected" <<<"$out" || fail 'hash mismatch'; pass 'SHA-256 path containing spaces'
if bash "$ROOT/lust-dar" hash "$TMP/missing" >/dev/null 2>&1; then fail 'missing file accepted'; fi
pass 'missing file rejected'
if bash "$ROOT/lust-dar" dns 'example.org;touch /tmp/lust-dar-injected' >/dev/null 2>&1; then fail 'invalid DNS name accepted'; fi
[[ ! -e /tmp/lust-dar-injected ]] || fail 'DNS input executed as shell'; pass 'DNS input validation'
if bash "$ROOT/lust-dar" unknown >/dev/null 2>&1; then fail 'unknown command accepted'; fi
pass 'unknown command rejected'

mkdir -p "$TMP/mockbin"
cat >"$TMP/mockbin/ip" <<'IP'
#!/usr/bin/env bash
case "$*" in
  '-brief address') printf 'lo UNKNOWN 127.0.0.1/8\n' ;;
  'route show') printf 'default dev lo\n' ;;
  *) exit 1 ;;
esac
IP
cat >"$TMP/mockbin/nslookup" <<'DNS'
#!/usr/bin/env bash
printf 'Mock DNS answer for %s\n' "$1"
DNS
chmod +x "$TMP/mockbin/ip" "$TMP/mockbin/nslookup"
PATH="$TMP/mockbin:$PATH" bash "$ROOT/lust-dar" network >"$TMP/network" || fail 'network command failed with mocked iproute2'
grep -q '127.0.0.1' "$TMP/network" || fail 'network output missing mocked interface'; pass 'network information with mocked iproute2'
PATH="$TMP/mockbin:$PATH" bash "$ROOT/lust-dar" dns example.org >"$TMP/dns" || fail 'DNS command failed with mocked resolver'
grep -q 'example.org' "$TMP/dns" || fail 'DNS output missing'; pass 'DNS command with mocked resolver (no external query)'
python3 - "$ROOT" <<'PY'
import os, socket, subprocess, sys
root = sys.argv[1]
listener = socket.socket()
listener.bind(('127.0.0.1', 0))
listener.listen(1)
port = str(listener.getsockname()[1])
result = subprocess.run(['bash', os.path.join(root, 'lust-dar'), 'scan', '127.0.0.1', port],
                        text=True, capture_output=True, timeout=8)
listener.close()
if result.returncode != 0 or 'OUVERT' not in result.stdout:
    raise SystemExit('FAIL: loopback TCP scan did not detect the local test listener: ' + result.stdout + result.stderr)
print('PASS: TCP scan against local loopback listener')
PY
if bash "$ROOT/lust-dar" scan 127.0.0.1 0 >/dev/null 2>&1; then fail 'invalid port accepted'; fi
pass 'invalid scan port rejected'
if bash "$ROOT/lust-dar" </dev/null >/dev/null 2>&1; then fail 'non-interactive default unexpectedly opened menu'; fi
pass 'non-interactive invocation displays help and exits'

mkdir -p "$TMP/fakebin" "$TMP/prefix/bin" "$TMP/home"
cat >"$TMP/fakebin/pkg" <<'PKG'
#!/usr/bin/env bash
printf 'fake pkg %s\n' "$*"
PKG
chmod +x "$TMP/fakebin/pkg"
PATH="$TMP/fakebin:$PATH" PREFIX="$TMP/prefix" HOME="$TMP/home" LUST_DAR_INSTALL_DIR="$TMP/home/installed with spaces" \
  bash "$ROOT/install-termux.sh" >"$TMP/install.log" || fail 'simulated Termux install failed'
grep -q 'Installation terminée' "$TMP/install.log" || fail 'installer completion not reported'
"$TMP/prefix/bin/lust-dar" --version | grep -q 'LUST-DAR 5.0.0-dev' || fail 'installed launcher failed'
pass 'Termux installer and installed launcher (pkg simulated)'

if PREFIX='' bash "$ROOT/install-termux.sh" >/dev/null 2>&1; then fail 'Termux installer accepted non-Termux environment'; fi
pass 'Termux installer refuses non-Termux environment'

python3 - "$ROOT" <<'PY'
import os, pty, select, subprocess, sys, time
root = sys.argv[1]
master, slave = pty.openpty()
env = os.environ.copy()
env['TERM'] = 'xterm-256color'
proc = subprocess.Popen(['bash', os.path.join(root, 'lust-dar')], stdin=slave,
                        stdout=slave, stderr=slave, env=env, close_fds=True)
os.close(slave)
os.write(master, b'00\n')
data = bytearray()
deadline = time.monotonic() + 5
while time.monotonic() < deadline and proc.poll() is None:
    ready, _, _ = select.select([master], [], [], 0.1)
    if ready:
        try:
            data.extend(os.read(master, 4096))
        except OSError:
            break
if proc.poll() is None:
    proc.kill()
    raise SystemExit('FAIL: menu did not exit within timeout')
try:
    while True:
        data.extend(os.read(master, 4096))
except OSError:
    pass
os.close(master)
if proc.returncode != 0 or b'L U S T' not in data or b'Session termin' not in data:
    raise SystemExit('FAIL: interactive menu/output incorrect: ' + repr(bytes(data[-1200:])))
print('PASS: interactive neon menu via pseudo-terminal')
PY

printf '\nTous les tests ont réussi.\n'
