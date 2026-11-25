# Hyper-V runtime acceptance

Date: 2026-11-26 (operator local date). Evidence: command output supplied by the operator from the Windows Hyper-V host and the Void guest named `voidlinux`. The package version was not separately printed by the guest in the supplied log. The current packaging candidate is 6.18.65_1 (x86_64 glibc).

## Observed results

- `sudo sv status hv-kvp-daemon`: run, PID 1488; logging process PID 1487.
- `pgrep -a hv_kvp_daemon`: `1488 hv_kvp_daemon -n`.
- Host `Get-VMIntegrationService -VMName voidlinux`: Key-Value Pair Exchange enabled, primary status OK; secondary protocol-version mismatch warning was present. Heartbeat, Shutdown and Time Synchronization reported OK.
- `Get-VMNetworkAdapter -VMName voidlinux | Select-Object IPAddresses`: IPv4 172.31.73.6 and link-local IPv6 fe80::197b:5916:2bfb:58b0, matching the earlier guest network output.
- `Stop-VM -Name voidlinux` without Force or TurnOff: VM state Off, Operating normally.
- `Start-VM -Name voidlinux`, followed by the same host IP query: the same IPv4 and IPv6 addresses were reported.

## Scope and decision

Basic KVP IP reporting and graceful guest shutdown meet the requirements for proceeding with the hyperv-manager Void profile and first package publication. The operator's output supports persistence of host IP reporting after power cycling; a separate post-reboot guest process check and DHCP address change test were not supplied. The protocol-version warning is not resolved. VSS, file copy and host-side IP injection are not validated (IP injection is deliberately unsupported). No claim of complete Hyper-V integration support is made.

CI run [45718942126](https://github.com/okedokii/hyperv-daemons/actions/runs/45718942126) passed the signing tests with a disposable key. Production signing, GitHub Pages deployment, and installation from the published remote repository still require verification. Publication rebuilds the package from source, so byte identity with the runtime-tested artifact is not established.
