---
"@inkeep/open-knowledge": patch
---

Publish a multi-arch (`linux/amd64`, `linux/arm64`) container image to `ghcr.io/inkeep/open-knowledge` with every release. Stable releases are tagged `X.Y.Z`, `X.Y` and `latest`; betas are tagged `X.Y.Z-beta.N` and `beta`. Images are signed with cosign keyless. Mount a volume at `/opt/data` and set `OK_ALLOW_EXTERNAL=1`:

```sh
docker run -p 8080:8080 -v ok-data:/opt/data -e OK_ALLOW_EXTERNAL=1 ghcr.io/inkeep/open-knowledge:latest
```

On first boot the container runs `ok init` on the empty volume, then `ok start`.
