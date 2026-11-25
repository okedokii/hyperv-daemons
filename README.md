# hyperv-daemons

Experimental XBPS packaging for Linux Hyper-V guest integration tools on Void Linux (x86_64 glibc). No systemd dependency. All three daemons, lsvmbus and runit service definitions are shipped in one package; Python 3 is required for lsvmbus.

## Build

The repository is an overlay for the official void-packages tree. CI uses a pinned upstream checkout, the official Void glibc container and xbps-src. Run the Build workflow or open a PR to obtain packages and SHA256SUMS as workflow artifacts.

## Status

- The initial two-package layout built locally and in hosted CI (run 45716763285), including artifact upload and SHA256SUMS. The final initial layout combines all tools into hyperv-daemons; its CI run 45717473424 passed, including file checks and artifact upload.
- The first release retains revision 1 and includes stderr redirection for both runit services. Compiler packed-member warnings in upstream file-copy code remain.
- Hosted CI run 45718942126 passed package construction, file checks, disposable-key signing, signature verification, tamper rejection and XBPS key import. Package upstream checks were disabled; this is not a full upstream test suite.
- Basic KVP and graceful shutdown acceptance passed on a real Hyper-V guest, as reported by the operator on 2026-11-26. See [acceptance record](docs/HYPERV-ACCEPTANCE.md).
- KVP is the primary target; VSS and file copy are not validated.
- Host IP injection is unsupported; services are opt-in.

## Acceptance

Install from a trusted local XBPS repository, enable host Data Exchange and the hv-kvp-daemon runit service. Compare guest IP with Get-VMNetworkAdapter on the host. Check daemon restart, guest reboot, DHCP address changes and graceful shutdown. Do not test VSS or file copy on production machines.

The manual signed XBPS repository publication workflow is ready for its first operator-triggered deployment; see [publishing instructions](docs/PUBLISHING.md). Basic KVP acceptance is recorded; VSS and file copy remain experimental. Production signing and remote installation have not yet been verified. Never use a personal self-hosted runner for untrusted public PRs.
