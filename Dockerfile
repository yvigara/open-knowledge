FROM node:26-alpine

# The server needs git at boot.
RUN apk add --no-cache \
  ca-certificates \
  git=~2.54

# CI always passes the release version; `latest` is for local builds.
ARG OK_VERSION=latest

RUN npm install -g \
  "@inkeep/open-knowledge@${OK_VERSION}" \
  @slidev/cli@53.0 \
  @slidev/theme-default@0.25

ENV OK_VERSION=${OK_VERSION}

# OK_ALLOW_EXTERNAL=1 is left to the operator; without it the server refuses to boot.
ENV PORT=8080
ENV OK_BIND=0.0.0.0
ENV OK_HOME=/opt/data

# No `VOLUME`: Railway and Fly reject it. Mount a volume at $OK_HOME to persist data.
WORKDIR ${OK_HOME}
EXPOSE 8080

COPY scripts/docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD [ ]
