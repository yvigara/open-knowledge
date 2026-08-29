FROM node:26-alpine

# git is a hard boot requirement: the server runs a git preflight at boot
# and the version-history subsystems shell out to the binary.
RUN apk add --no-cache \
  ca-certificates \
  git=~2.54

# The npm version of @inkeep/open-knowledge this image ships.
# CI pins it from the release tag being built (v0.63.6 -> 0.63.6), so a
# tagged image and its npm release are the same code by construction.
# The `latest` default is for local `docker build .` only; every image
# published from .github/workflows/docker.yaml passes an explicit version.
ARG OK_VERSION=latest

RUN npm install -g \
  "@inkeep/open-knowledge@${OK_VERSION}" \
  @slidev/cli@52.19 \
  @slidev/theme-default@0.25

# Recorded so a running container can name its own version without a
# registry round-trip (`docker inspect`, or `echo $OK_VERSION` inside).
ENV OK_VERSION=${OK_VERSION}

# PORT is the platform-injection contract: Railway/Fly/Cloud Run override
# it at run time. 8080 is only the local default.
# OK_BIND=0.0.0.0 makes the listener reachable from the container network.
# Consent (OK_ALLOW_EXTERNAL=1) is deliberately NOT baked: a run without it
# refuses to boot and names the fix. That refusal is the secure default.
ENV PORT=8080
ENV OK_BIND=0.0.0.0
ENV OK_HOME=/opt/data

# No `VOLUME`: managed builders (Railway, Fly) reject the instruction, and
# for plain `docker run` it only creates anonymous volumes. Persistence is
# the operator's job: mount a volume at $OK_HOME (/opt/data), or data lives
# in the container layer and is lost on recreate.
WORKDIR ${OK_HOME}
EXPOSE 8080

COPY scripts/docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD [ ]
