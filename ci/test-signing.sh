#!/bin/sh
set -eu
umask 077
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
openssl genrsa -traditional -out "$tmp/key.pem" 4096
openssl pkey -in "$tmp/key.pem" -pubout -outform DER -out "$tmp/public.der"
expected=$(sha256sum "$tmp/public.der" | cut -d ' ' -f 1)
umask 022
mkdir "$tmp/repo"
sh /overlay/ci/sign-repository.sh /input "$tmp/repo" "$tmp/key.pem" "$expected"
test -s "$tmp/repo/PUBLIC-KEY-SHA256"
test -s "$tmp/repo/XBPS-KEY-FILENAME"
