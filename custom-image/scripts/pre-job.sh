#!/bin/bash

echo "Running docker image version [${DOCKER_IMAGE_VERSION}]."

if [ -n "$GITHUB_TOKEN" ]; then
  echo "Logging into GitHub CLI with provided token."
  echo "$GITHUB_TOKEN" | gh auth login --with-token
fi

echo "Running pre-job script finished."