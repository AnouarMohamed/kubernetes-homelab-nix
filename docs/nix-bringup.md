# Build-only configuration placeholders

No value in `nix/config.nix` is suitable for deployment. Replace every item
below in a private deployment overlay; never commit the real values.

| Placeholder | Meaning |
| --- | --- |
| `PLACEHOLDER.example.invalid` | Public base domain |
| `admin@PLACEHOLDER.example.invalid` | ACME contact |
| `192.0.2.10` | Control-plane virtual IP (TEST-NET-1) |
| `192.0.2.11`–`192.0.2.13` | Three node addresses |
| `192.0.2.20`–`192.0.2.39` | Load-balancer pool |
| `s3.PLACEHOLDER.example.invalid` | Object-storage endpoint |
| `PLACEHOLDER-homelab-backups` | Object-storage bucket |
| `REPLACE_WITH_SSH_ED25519_PUBLIC_KEY` | Administrator SSH public key |
| `REPLACE_WITH_AGE_RECIPIENT` | sops age recipient |
| `REPLACE_WITH_CLOUDFLARE_ACCOUNT_ID` | Terranix variable placeholder |
| `REPLACE_WITH_CLOUDFLARE_ZONE_ID` | Terranix variable placeholder |
| `REPLACE_WITH_INSTALL_DISK` | Stable disk by-id path for each host |
| `00000000-0000-0000-0000-000000000000` | Cloudflare tunnel UUID |

The committed `secrets/placeholder.json` is deliberately non-decryptable SOPS
structure. Replace it with a genuinely encrypted file in a deployment overlay.

