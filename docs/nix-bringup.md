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
| `REPLACE_WITH_SSH_ED25519_PUBLIC_KEY` | Administrator SSH public key |
| `REPLACE_WITH_AGE_RECIPIENT` | sops age recipient |
| `REPLACE_WITH_CLOUDFLARE_ACCOUNT_ID` | Terranix variable placeholder |
| `REPLACE_WITH_CLOUDFLARE_ZONE_ID` | Terranix variable placeholder |

