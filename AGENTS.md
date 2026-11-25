# Agent rules
- Keep this repository an XBPS packaging overlay; do not vendor void-packages or Linux sources.
- Pin the upstream void-packages revision and verify upstream source checksums.
- Use GitHub-hosted Linux CI for public pull requests. Never run untrusted PR code on personal self-hosted runners.
- Keep services opt-in, preserve fail-closed IP injection, and do not claim runtime acceptance based on a successful build.
- Require green CI and real Hyper-V acceptance before publishing a verified release. Never commit credentials, keys or binary artifacts.
- Keep README and acceptance results current.
