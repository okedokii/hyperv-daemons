#!/bin/sh
set -eu
umask 022
# Usage: sign-repository.sh INPUT_DIR OUTPUT_DIR PRIVATE_KEY EXPECTED_PUBLIC_SHA256
# INPUT_DIR is the trusted output of the build job. OUTPUT_DIR must be empty.
input=$1
out=$2
key=$3
expected=$4
test -n "$expected"
test -d "$input"
test -d "$out"
test -f "$key"
test -z "$(ls -A "$out")"
tmp=$(mktemp -d)
server=
trap 'if [ -n "$server" ]; then kill "$server" 2>/dev/null || :; fi; rm -rf "$tmp"' EXIT
trap 'exit 1' HUP INT TERM
openssl pkey -in "$key" -pubout -out "$tmp/public.pem"
openssl pkey -pubin -in "$tmp/public.pem" -outform DER -out "$tmp/public.der"
actual=$(sha256sum "$tmp/public.der" | cut -d ' ' -f 1)
test "$actual" = "$expected" || { echo 'Signing key fingerprint mismatch' >&2; exit 1; }
# Accept exactly the package produced by CI, not arbitrary files.
set -- "$input"/hyperv-daemons-[0-9]*.x86_64.xbps
test "$#" -eq 1
test -s "$1"
pkg=${1##*/}
(cd "$input" && sha256sum -c SHA256SUMS)
cp "$1" "$out/$pkg"
xbps-rindex -a "$out/$pkg"
xbps-rindex --privkey "$key" --signedby "okedokii/hyperv-daemons" --sign "$out"
xbps-rindex --privkey "$key" --sign-pkg "$out/$pkg"
test -s "$out/x86_64-repodata"
test -s "$out/$pkg.sig2"
openssl dgst -sha256 -verify "$tmp/public.pem" -signature "$out/$pkg.sig2" "$out/$pkg"
cp "$out/$pkg" "$tmp/tampered.xbps"
printf 'tampered' >> "$tmp/tampered.xbps"
if openssl dgst -sha256 -verify "$tmp/public.pem" -signature "$out/$pkg.sig2" "$tmp/tampered.xbps"; then
    echo 'Tampered package was accepted' >&2
    exit 1
fi
# Exercise XBPS remote repository synchronization and key import against our
# isolated loopback server only. Never auto-trust arbitrary remote keys.
python3 -m http.server 8765 --bind 127.0.0.1 --directory "$out" > "$tmp/http.log" 2>&1 &
server=$!
python3 - <<'PY'
import time, urllib.request
for _ in range(50):
    try:
        with urllib.request.urlopen("http://127.0.0.1:8765/x86_64-repodata", timeout=1) as response:
            assert response.status == 200
        break
    except OSError:
        time.sleep(0.1)
else:
    raise SystemExit("Local XBPS repository server did not start")
PY
mkdir "$tmp/root"
xbps-install -Syi -r "$tmp/root" --repository=http://127.0.0.1:8765
set -- "$tmp/root"/var/db/xbps/keys/*.plist
test "$#" -eq 1
test -s "$1"
# The imported native key must correspond to the pinned public key.
python3 - "$1" "$tmp/public.pem" <<'PY'
import plistlib, sys
with open(sys.argv[1], "rb") as f:
    key = plistlib.load(f)["public-key"]
with open(sys.argv[2], "rb") as f:
    expected = f.read()
if key.strip() != expected.strip():
    raise SystemExit("Imported XBPS public key does not match signing key")
PY
mkdir "$out/keys"
cp "$1" "$out/keys/"
cp "$tmp/public.pem" "$out/public.pem"
printf '%s\n' "$actual" > "$out/PUBLIC-KEY-SHA256"
printf '%s\n' "${1##*/}" > "$out/XBPS-KEY-FILENAME"
# Public files only. The private key is never copied into this directory.
touch "$out/.nojekyll"
printf '%s\n' 'Signed hyperv-daemons XBPS repository for Void Linux x86_64 glibc.' > "$out/index.txt"
(cd "$out" && sha256sum "$pkg" "$pkg.sig2" x86_64-repodata > SHA256SUMS)
chmod -R a+rX "$out"
