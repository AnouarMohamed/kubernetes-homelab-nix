# Security policy

## Reporting a vulnerability

Use GitHub's private vulnerability reporting feature for this repository. Do
not open a public issue for an unpatched vulnerability or include credentials,
private addresses, hostnames, decrypted secrets, logs, or support bundles.

Include the affected commit or image digest, impact, reproducible steps, and
any known mitigation. You should receive acknowledgement within seven days.
Disclosure timing will be coordinated after impact is understood and a fix is
available.

## Supported versions

Only the current `main` branch and the latest immutable Sentinel image release
are supported. Older images and forks may not receive fixes.

## Scope

Build definitions, NixOS modules, Kubernetes policy, CI workflows, Sentinel,
and published GHCR images are in scope. The placeholder environment and any
third-party deployment using changed overlays are not operated by this project.

