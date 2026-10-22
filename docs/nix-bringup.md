# Deployment placeholders and acceptance

No value in `nix/config.nix` is suitable for deployment. Supply every value in
a private deployment overlay; never commit real infrastructure identifiers or
credentials.

## Required replacements

| Placeholder | Meaning |
| --- | --- |
| `placeholder.example.invalid` | Public base domain |
| `admin@placeholder.example.invalid` | ACME contact |
| `192.0.2.0/24` | Administrator and example private-route CIDR |
| `192.0.2.10` | Control-plane virtual IP (TEST-NET-1) |
| `192.0.2.11`–`192.0.2.13` | Three node addresses |
| `192.0.2.20`–`192.0.2.39` | Load-balancer pool |
| `s3.placeholder.example.invalid` | Object-storage endpoint |
| `placeholder-homelab-backups` | Object-storage bucket |
| `REPLACE_WITH_SSH_ED25519_PUBLIC_KEY` | Administrator SSH public key |
| `REPLACE_WITH_AGE_RECIPIENT` | SOPS age recipient |
| `REPLACE_WITH_CLOUDFLARE_ACCOUNT_ID` | Terranix account identifier |
| `REPLACE_WITH_CLOUDFLARE_ZONE_ID` | Terranix zone identifier |
| `REPLACE_WITH_NODE1_INSTALL_DISK` | Node 1 stable `/dev/disk/by-id/` identifier |
| `REPLACE_WITH_NODE2_INSTALL_DISK` | Node 2 stable `/dev/disk/by-id/` identifier |
| `REPLACE_WITH_NODE3_INSTALL_DISK` | Node 3 stable `/dev/disk/by-id/` identifier |
| `REPLACE_WITH_HOST_TUNNEL_ID` | Optional, separately provisioned host private-route tunnel |

`hostTunnel.enable` defaults to false. Application ingress belongs to the
Kubernetes cloudflared deployment; do not configure a host service with the
same tunnel identity.

The committed `secrets/placeholder.json` is deliberately non-decryptable SOPS
structure. Replace it with a genuinely encrypted file outside the public
configuration and keep all age private keys out of the Nix store.

## Preflight

1. Confirm each disk identifier on its exact target host. The installer will
   repartition that disk.
2. Reserve node addresses and the control-plane VIP; verify they cannot be
   leased to another device.
3. Validate MTU, DNS, NTP, object-store TLS, bucket policy, and Cloudflare
   ownership from the target network.
4. Build all three `nixosConfigurations`, the installer ISO, and manifests from
   the locked flake.
5. Review `rendered/all.yaml`, the selected kubectl context, and every secret
   reference before bootstrap.

## Acceptance evidence

Do not call the deployment production-ready until evidence exists for:

- one-node control-plane loss and clean etcd recovery;
- workload rescheduling without unplanned data loss;
- Longhorn disk/replica loss and rebuild;
- PostgreSQL point-in-time or backup restore into isolation;
- Velero restore from the actual off-cluster bucket;
- certificate renewal, public DNS, and tunnel failover;
- image signature enforcement using a workflow-published release;
- alert delivery and the documented SLO burn path.

Record dates, Git revisions, image digests, achieved RPO/RTO, and follow-up
owners. Until then, those behaviors are **UNVERIFIED**.
