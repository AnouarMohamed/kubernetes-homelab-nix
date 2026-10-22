{
  github = {
    name = "Production validation";
    "on" = {
      push.branches = [ "main" ];
      pull_request = { };
      workflow_dispatch = { };
    };
    concurrency = {
      group = "\${{ github.workflow }}-\${{ github.ref }}";
      cancel-in-progress = true;
    };
    permissions.contents = "read";
    jobs = {
      nix = {
        runs-on = "ubuntu-24.04";
        timeout-minutes = 60;
        steps = [
          { uses = "actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803"; }
          {
            uses = "cachix/install-nix-action@448cde739abec1eaf0646249e3d25bb8d9bc7702";
            "with" = {
              github_access_token = "\${{ secrets.GITHUB_TOKEN }}";
              extra_nix_config = "experimental-features = nix-command flakes";
            };
          }
          {
            name = "Evaluate every output";
            run = "nix flake show --all-systems";
          }
          {
            name = "Run the full locked check graph";
            run = "nix flake check --keep-going --print-build-logs";
          }
          {
            name = "Build auditable deployment artifact";
            run = "nix build .#manifests --out-link rendered-result --print-build-logs";
          }
          {
            name = "Upload rendered deployment artifact";
            uses = "actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02";
            "with" = {
              name = "rendered-kubernetes-manifest";
              path = "rendered-result";
              if-no-files-found = "error";
              retention-days = 14;
            };
          }
        ];
      };
      sentinel = {
        runs-on = "ubuntu-24.04";
        timeout-minutes = 15;
        defaults.run.working-directory = "apps/sentinel";
        services.postgres = {
          image = "docker.io/library/postgres:17.6-bookworm@sha256:f3bd19c606e442c3d7bdfa8002e03fe260a1023351e0ea4598032022b68dd6e3";
          env = {
            POSTGRES_DB = "sentinel_test";
            POSTGRES_USER = "sentinel";
            POSTGRES_PASSWORD = "sentinel-test-only";
          };
          ports = [ "5432:5432" ];
          options = "--health-cmd pg_isready --health-interval 5s --health-timeout 5s --health-retries 10";
        };
        steps = [
          { uses = "actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803"; }
          {
            uses = "actions/setup-go@924ae3a1cded613372ab5595356fb5720e22ba16";
            "with" = {
              go-version-file = "apps/sentinel/go.mod";
              cache-dependency-path = "apps/sentinel/go.sum";
            };
          }
          {
            name = "Unit tests with race detector";
            run = "go test -race -coverprofile=coverage.out ./...";
          }
          {
            name = "Static analysis";
            run = "go vet ./...";
          }
          {
            name = "PostgreSQL integration tests";
            env.DATABASE_URL = "postgres://sentinel:sentinel-test-only@127.0.0.1:5432/sentinel_test?sslmode=disable";
            run = "go test -race -tags=integration ./internal/database";
          }
          {
            name = "Upload coverage";
            uses = "actions/upload-artifact@ea165f8d65b6e75b540449e92b4886f43607fa02";
            "with" = {
              name = "sentinel-coverage";
              path = "apps/sentinel/coverage.out";
              if-no-files-found = "error";
              retention-days = 14;
            };
          }
        ];
      };
    };
  };

  githubRelease = {
    name = "Publish Sentinel images";
    "on" = {
      push.tags = [ "sentinel-v*" ];
      workflow_dispatch.inputs.version = {
        description = "Immutable release tag, for example v0.4.0";
        required = true;
        type = "string";
      };
    };
    concurrency = {
      group = "sentinel-images-\${{ github.ref }}";
      cancel-in-progress = false;
    };
    permissions = {
      contents = "read";
      id-token = "write";
      packages = "write";
    };
    jobs.publish = {
      runs-on = "ubuntu-24.04";
      timeout-minutes = 45;
      strategy = {
        fail-fast = false;
        matrix.component = [
          "api"
          "worker"
        ];
      };
      steps = [
        { uses = "actions/checkout@d23441a48e516b6c34aea4fa41551a30e30af803"; }
        {
          name = "Validate immutable SemVer release";
          env.REQUESTED_VERSION = "\${{ github.event_name == 'workflow_dispatch' && inputs.version || github.ref_name }}";
          run = ''
            set -euo pipefail
            version="''${REQUESTED_VERSION#sentinel-}"
            if [[ ! "$version" =~ ^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$ ]]; then
              echo "Release must be canonical SemVer such as v0.4.0; got: $version" >&2
              exit 1
            fi
            echo "RELEASE_VERSION=$version" >> "$GITHUB_ENV"
          '';
        }
        { uses = "docker/setup-qemu-action@c7c53464625b32c7a7e944ae62b3e17d2b600130"; }
        { uses = "docker/setup-buildx-action@8d2750c68a42422c14e847fe6c8ac0403b4cbd6f"; }
        {
          uses = "docker/login-action@c94ce9fb468520275223c153574b00df6fe4bcc9";
          "with" = {
            registry = "ghcr.io";
            username = "\${{ github.actor }}";
            password = "\${{ secrets.GITHUB_TOKEN }}";
          };
        }
        {
          name = "Refuse to overwrite an existing release";
          env.IMAGE = "ghcr.io/anouarmohamed/homelab-nix-sentinel-\${{ matrix.component }}";
          run = ''
            if docker buildx imagetools inspect "$IMAGE:$RELEASE_VERSION" >/dev/null 2>&1; then
              echo "Refusing to overwrite immutable image $IMAGE:$RELEASE_VERSION" >&2
              exit 1
            fi
          '';
        }
        {
          id = "meta";
          uses = "docker/metadata-action@c299e40c65443455700f0fdfc63efafe5b349051";
          "with" = {
            images = "ghcr.io/anouarmohamed/homelab-nix-sentinel-\${{ matrix.component }}";
            tags = ''
              type=raw,value=''${{ env.RELEASE_VERSION }}
              type=sha,prefix=sha-
            '';
          };
        }
        {
          id = "build";
          uses = "docker/build-push-action@10e90e3645eae34f1e60eeb005ba3a3d33f178e8";
          "with" = {
            context = "apps/sentinel";
            file = "apps/sentinel/Dockerfile.\${{ matrix.component }}";
            platforms = "linux/amd64,linux/arm64";
            push = true;
            tags = "\${{ steps.meta.outputs.tags }}";
            labels = "\${{ steps.meta.outputs.labels }}";
            build-args = ''
              VERSION=''${{ steps.meta.outputs.version }}
              REVISION=''${{ github.sha }}
            '';
            provenance = "mode=max";
            sbom = true;
            cache-from = "type=gha,scope=sentinel-\${{ matrix.component }}";
            cache-to = "type=gha,mode=max,scope=sentinel-\${{ matrix.component }}";
          };
        }
        { uses = "sigstore/cosign-installer@6f9f17788090df1f26f669e9d70d6ae9567deba6"; }
        {
          name = "Keyless-sign the immutable index";
          env.IMAGE = "ghcr.io/anouarmohamed/homelab-nix-sentinel-\${{ matrix.component }}";
          run = ''
            cosign sign --yes "$IMAGE@''${{ steps.build.outputs.digest }}"
          '';
        }
      ];
    };
  };

  gitlab = {
    stages = [ "validate" ];
    "nix:flake-check" = {
      stage = "validate";
      tags = [ "nix" ];
      script = [ "nix flake check --keep-going --print-build-logs" ];
    };
  };
}
