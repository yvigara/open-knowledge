#!/bin/sh
# shellcheck shell=sh
# First-boot init: scaffold the project exactly once, on an empty volume.
# An initialized or restored volume starts the server.
# stdin is closed so `ok init` takes its non-TTY defaults and can never
# hang on a prompt.
set -eu

OK_HOME="${OK_HOME:-/opt/data}"

# The image's WORKDIR is baked at build time, so a run-time
# `-e OK_HOME=...` override would leave the working directory at the image
# default: `ok init` (which has no OK_HOME of its own — it writes .ok into
# the cwd) would scaffold one path while the guard below read another, and
# the once-only guard would never trip. cd makes the override real.
# 2>/dev/null: sh's own "can't cd to ..." adds nothing to the message below.
if ! cd "${OK_HOME}" 2>/dev/null; then
  echo "[entrypoint] OK_HOME=${OK_HOME} does not exist. Mount a volume there, or unset OK_HOME to use the image default." >&2
  exit 1
fi

if [ ! -d "${OK_HOME}/.ok" ]; then
  echo "[entrypoint] ${OK_HOME} is not initialized. Running ok init --no-mcp --no-skills"
  ok init --no-mcp --no-skills </dev/null
fi
exec ok start
