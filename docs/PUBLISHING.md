# Signed XBPS repository

Publication is manual, from main only, after green CI and successful real Hyper-V acceptance. No PR can invoke the production signing job. The Pages deployment is a separate job without access to the signing key.

## One-time owner setup

On a trusted machine, outside the repository, create a dedicated RSA key:

```sh
umask 077
mkdir -p ~/.local/share/hyperv-signing
cd ~/.local/share/hyperv-signing
openssl genrsa -traditional -out private.pem 4096
openssl pkey -in private.pem -pubout -out public.pem
openssl pkey -pubin -in public.pem -outform DER -out public.der
sha256sum public.der
```

Keep a protected backup of private.pem. Never commit it or send it through chat. In GitHub Settings > Environments create xbps-signing, restrict deployment branches to main (not tags), and set an environment secret XBPS_PRIVATE_KEY to the PEM contents and environment variable XBPS_PUBLIC_KEY_SHA256 to the 64-character digest above. Enable required reviewers if available. In Settings > Pages select GitHub Actions as source. Retain the public digest independently.

## Publish

After runtime acceptance, run Publish signed XBPS repository manually on main. It builds, tests with a disposable key, signs with the production key in an isolated container, checks the public digest, verifies the package signature and rejects tampering, synchronizes a loopback XBPS repository and exports the native trusted-key plist. The site artifact contains public files only. Do not re-publish changed bytes with the same pkgver. The site is a current snapshot, not a historical package archive.

Expected URL: https://okedokii.github.io/hyperv-daemons/

## Install

Once publication is live:

```sh
echo 'repository=https://okedokii.github.io/hyperv-daemons/' | sudo tee /etc/xbps.d/20-hyperv.conf
sudo xbps-install -S hyperv-daemons
```

Compare the XBPS key fingerprint with the maintainer's independently trusted value before accepting. The XBPS key fingerprint is the filename stem published in XBPS-KEY-FILENAME, not the SHA256 of the DER public key. Verify the PEM against the independently recorded DER SHA256. Automation must pin the actual XBPS public key plist (in /var/db/xbps/keys), acquired and verified through a trusted channel; do not auto-accept keys from the remote repository. Do not use an HTTP mirror when HTTPS is available. XBPS verifies package signatures; repository metadata alone does not prevent replay of older valid packages.

## Limitations

The test checks signing, cryptographic tamper rejection and native key import, not VMBus runtime or the full remote installation transaction. The signing container uses the official Void image tag and current package repositories; it is not a bit-for-bit reproducible build. The real signing secret and Pages configuration must be set by the repository owner. Do not publish until acceptance is documented.
