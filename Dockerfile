FROM node:26-alpine@sha256:143494b1da2945f061539253adc65e4f1569ddf07da2d384c022c791a9d90a4a

ARG OK_VERSION

# git: the server needs it at boot.
# tini: ok must not be PID 1, its lock file treats pid < 2 as invalid.
RUN apk add --no-cache ca-certificates git=~2.54 tini

RUN test -n "${OK_VERSION}" || { echo "--build-arg OK_VERSION is required" >&2; exit 1; }
RUN npm install -g \
    "@inkeep/open-knowledge@${OK_VERSION}" \
    @slidev/cli@53.0 \
    @slidev/theme-default@0.25 \
  && npm cache clean --force
RUN INSTALLED="$(ok --version | head -n 1 | tr -d '[:space:]')" \
  && [ "${INSTALLED#v}" = "${OK_VERSION}" ] \
  || { echo "ok --version is ${INSTALLED}, expected ${OK_VERSION}" >&2; exit 1; }

COPY --chmod=0755 scripts/docker/entrypoint.sh /usr/local/bin/entrypoint.sh

# No `VOLUME`: Railway and Fly reject it. Mount a volume at $OK_HOME to persist data.
ENV OK_HOME=/opt/data
RUN mkdir -p "${OK_HOME}" && chown node:node "${OK_HOME}"
WORKDIR ${OK_HOME}
USER node

# OK_ALLOW_EXTERNAL=1 is left to the operator; without it the server refuses to boot.
ENV OK_VERSION=${OK_VERSION}
ENV PORT=8080
ENV OK_BIND=0.0.0.0
EXPOSE 8080

LABEL org.opencontainers.image.title="open-knowledge" \
      org.opencontainers.image.source="https://github.com/inkeep/open-knowledge" \
      org.opencontainers.image.licenses="GPL-3.0-or-later" \
      org.opencontainers.image.version="${OK_VERSION}"

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD wget -q -O /dev/null "http://127.0.0.1:${PORT}/healthz" || exit 1

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/entrypoint.sh"]
