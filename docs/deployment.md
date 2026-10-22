# Deployment contract and acceptance

The committed configuration is a complete private-LAN reference profile for
three identical PCs. It deliberately uses the IANA-reserved `home.arpa` domain
and a dedicated RFC1918 subnet; it contains no cloud account identifiers,
tunnel credentials, decryption recipients, or public infrastructure addresses.

## Committed hardware and LAN profile

| Setting | Value |
| --- | --- |
| Nodes | `node1`, `node2`, `node3` |
| CPU and memory | Intel Core i7-8650U, 4 cores / 8 threads, 32 GiB each |
| Storage | Geonix Supersonic 512 GB SATA SSD |
| Disk controller path | `/dev/disk/by-path/pci-0000:00:17.0-ata-3` |
| Wired interface | `enp0s31f6` |
| Node addresses | `10.10.0.11` through `10.10.0.13` |
| Kubernetes API VIP | `10.10.0.10` |
| Service address pool | `10.10.0.20` through `10.10.0.39` |
| Internal domain | `lab.home.arpa` |

These values are operational defaults, not claims about an existing network.
Reserve the subnet and addresses before deployment. Disko will destroy the
configured disk, so confirm its model, capacity, and controller path on every
machine from the installer environment.

## Private production inputs

Public ingress and secrets are intentionally fail-closed. A downstream private
flake or deployment module must provide:

- an encrypted SOPS file and its dedicated age recipient;
- the same high-entropy k3s token on all three nodes, either through SOPS or at
  `/var/lib/homelab-secrets/k3s-token` with mode `0400`;
- Cloudflare account ID, zone ID, public domain, and credentials as Terranix
  variables or secret environment variables at plan/apply time;
- a public ACME contact and domain if public TLS is enabled;
- an off-cluster S3 endpoint, bucket, access policy, retention policy, and
  credentials for disaster recovery;
- a host tunnel ID only when enabling the separate private-route host tunnel.

The administrator SSH key is a public credential and is committed explicitly.
Private SSH and age keys never enter this repository or the Nix store.

## Preflight

1. Confirm `/dev/disk/by-path/pci-0000:00:17.0-ata-3` resolves to the intended
   512 GB disk on each target host.
2. Confirm `enp0s31f6` is the wired interface on all three PCs.
3. Reserve node addresses, the control-plane VIP, and service pool; verify that
   DHCP cannot lease them to another device.
4. Validate MTU, DNS, NTP, object-store TLS, bucket policy, and edge ownership
   from the target network.
5. Build all three NixOS configurations, the installer ISO, and manifests from
   the locked flake.
6. Review `rendered/all.yaml`, the selected kubectl context, and every secret
   reference before bootstrap.

## Acceptance evidence

Do not call a physical deployment production-ready until evidence exists for:

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
