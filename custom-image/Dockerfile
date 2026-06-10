FROM ghcr.io/actions/actions-runner:2.335.1

USER root

ARG DOTNET_CHANNEL=10.0
ARG DOTNET_SDK_VERSION=10.0.301

RUN apt-get update && \
    apt-get install -y wget curl && \
    mkdir -p -m 755 /etc/apt/keyrings && \
    out=$(mktemp) && wget -nv -O $out https://cli.github.com/packages/githubcli-archive-keyring.gpg && \
    cat $out | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null && \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh && \
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

RUN dotnet_install_args="--install-dir /usr/share/dotnet --skip-non-versioned-files" && \
    if [ -n "${DOTNET_SDK_VERSION}" ]; then \
      dotnet_install_args="${dotnet_install_args} --version ${DOTNET_SDK_VERSION}"; \
    else \
      dotnet_install_args="${dotnet_install_args} --channel ${DOTNET_CHANNEL}"; \
    fi && \
    curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh && \
    chmod +x /tmp/dotnet-install.sh && \
    /tmp/dotnet-install.sh ${dotnet_install_args} && \
    rm /tmp/dotnet-install.sh && \
    /usr/share/dotnet/dotnet --info

# Bake pre-job.sh into the image
# ACTIONS_RUNNER_HOOK_JOB_STARTED=/home/runner/scripts/pre-job.sh
# https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/running-scripts-before-or-after-a-job
COPY custom-image/scripts/pre-job.sh /home/runner/scripts/pre-job.sh
RUN chmod +x /home/runner/scripts/pre-job.sh

ARG IMG_VERSION=InvalidBuildSetup
# Allows usage and installation of -g (global) tools
ENV DOTNET_ROOT=/usr/share/dotnet
ENV DOTNET_INSTALL_DIR=/usr/share/dotnet
ENV PATH="${PATH}:/usr/share/dotnet:/root/.dotnet/tools"
ENV DOCKER_IMAGE_VERSION=${IMG_VERSION}