# hyperv-daemons

Experimental XBPS packaging for Linux Hyper-V guest integration tools on Void Linux (x86_64 glibc). No systemd dependency. All three daemons, lsvmbus and runit service definitions are shipped in one package; Python 3 is required for lsvmbus.

## Build

The repository is an overlay for the official void-packages tree. CI uses a pinned upstream checkout, the official Void glibc container and xbps-src. Run the Build workflow or open a PR to obtain packages and SHA256SUMS as workflow artifacts.

## Status

- The initial two-package layout built locally and in hosted CI (run 45716763285), including artifact upload and SHA256SUMS. The final initial layout combines all tools into hyperv-daemons; its CI run is pending.
- The first release retains revision 1 and includes stderr redirection for both runit services. Compiler packed-member warnings in upstream file-copy code remain.
- Package tests were disabled in the reported local build. Real Hyper-V acceptance is pending.
- KVP is the primary target; VSS and file copy are not validated.
- Host IP injection is unsupported; services are opt-in.

## Acceptance

Install from a trusted local XBPS repository, enable host Data Exchange and the hv-kvp-daemon runit service. Compare guest IP with Get-VMNetworkAdapter on the host. Check daemon restart, guest reboot, DHCP address changes and graceful shutdown. Do not test VSS or file copy on production machines.

Releases are intentionally not automated until the package has passed real Hyper-V acceptance. Never use a personal self-hosted runner for untrusted public PRs.
