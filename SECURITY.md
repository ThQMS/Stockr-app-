# Security Policy

## Supported versions

| Version | Supported |
|---------|-----------|
| 1.0.x   | ✅        |

## Reporting a vulnerability

Please **do not** open a public issue for security problems.

Instead, report privately through GitHub's
[Security Advisories](https://github.com/ThQMS/Stockr-app-/security/advisories/new),
or email the maintainer at **thqueirozsilva@gmail.com**.

Include:

- A description of the issue and its impact.
- Steps to reproduce (proof of concept if possible).
- Affected version / commit.

You can expect an acknowledgement within a few days. Please give a reasonable
window to ship a fix before any public disclosure.

## Scope & handling secrets

- Never commit signing keys (`*.jks`, `*.keystore`, `key.properties`) or `.env`
  secrets — these are git-ignored by design.
- API credentials and tokens are stored on-device via
  `flutter_secure_storage`, not in plain preferences.
- The API base URL is injected at build time (`--dart-define=API_BASE_URL`), not
  hard-coded.
