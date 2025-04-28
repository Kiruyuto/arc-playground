#!/bin/bash
set -euo pipefail
echo "Running docker image version [${DOCKER_IMAGE_VERSION}]."

if [ -n "${CLI_PAT_TOKEN:-}" ]; then
  echo "Logging into GitHub CLI with provided token."
  echo "$CLI_PAT_TOKEN" | gh auth login --with-token
fi

echo "Running pre-job script finished."