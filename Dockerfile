# /custom_piper_uploader/Dockerfile
#
# NEW: Specify the Debian base image explicitly. This is the key to the fix.
# See: https://developers.home-assistant.io/docs/add-ons/base-images
ARG BUILD_FROM
FROM homeassistant/amd64-base-debian:bullseye

# Use Debian's package manager 'apt-get'
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    build-essential \
    python3-dev \
    python3-pip \
    python3-venv \
    espeak-ng \
    espeak-ng-dev \
    cmake \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create and activate a virtual environment for Python packages
RUN python3 -m venv /opt/venv

# Install Python dependencies into the virtual environment
RUN . /opt/venv/bin/activate && \
    pip install --no-cache-dir \
        flask \
        wyoming-piper \
        espeak-ng-phonemizer

# Copy rootfs contents to the image
COPY rootfs/ /

# Make run.sh executable
RUN chmod +x /run.sh

CMD [ "/run.sh" ]
