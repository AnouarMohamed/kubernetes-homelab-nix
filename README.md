# kubernetes-homelab-nix

A build-only, reproducible Nix reimplementation of the three-node HA k3s
platform in [`AnouarMohamed/kubernetes-homelab`](https://github.com/AnouarMohamed/kubernetes-homelab).
It is an engineering showcase: the configurations build and the Kubernetes
resources render and validate without access to homelab hardware or cloud
accounts.

```console
nix flake check
nix build .#manifests
nix run .#render
```

The committed `rendered/` tree is generated. Do not edit it directly. See
[`docs/nix-migration.md`](docs/nix-migration.md) for parity and verification
status and [`docs/nix-bringup.md`](docs/nix-bringup.md) for placeholder values.

