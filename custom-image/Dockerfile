FROM ghcr.io/actions/actions-runner:2.327.0

USER root

RUN apt-get update && \
    apt-get install -y wget && \
    mkdir -p -m 755 /etc/apt/keyrings && \
    out=$(mktemp) && wget -nv -O $out https://cli.github.com/packages/githubcli-archive-keyring.gpg && \
    cat $out | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null && \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

# Bake pre-job.sh into the image
# ACTIONS_RUNNER_HOOK_JOB_STARTED=/home/runner/scripts/pre-job.sh
# https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/running-scripts-before-or-after-a-job
COPY custom-image/scripts/pre-job.sh /home/runner/scripts/pre-job.sh
RUN chmod +x /home/runner/scripts/pre-job.sh

ARG IMG_VERSION=InvalidBuildSetup
# Allows usage and installation of -g (global) tools
ENV PATH="${PATH}:/root/.dotnet/tools"
ENV DOCKER_IMAGE_VERSION=${IMG_VERSION}