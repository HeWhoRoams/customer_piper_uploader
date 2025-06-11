# /custom_piper_uploader/Dockerfile
ARG BUILD_FROM
FROM ${BUILD_FROM}

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install build dependencies and Python
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-dev \
    python3-pip \
    python3-venv \
    espeak-ng \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Piper and Wyoming dependencies into a virtual environment
RUN python3 -m venv /opt/venv && \
    . /opt/venv/bin/activate && \
    pip install --no-cache-dir \
        flask \
        wyoming-piper \
        espeak-ng-phonemizer && \
    deactivate

# Copy rootfs contents to the image
COPY rootfs/ /

# Make run.sh executable
RUN chmod +x /run.sh

CMD [ "/run.sh" ]