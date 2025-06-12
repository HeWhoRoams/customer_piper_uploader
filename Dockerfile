# /custom_piper_uploader/Dockerfile
ARG BUILD_FROM
FROM ${BUILD_FROM}

# Use Alpine's package manager 'apk' instead of 'apt-get'
# --no-cache is a best practice that updates, installs, and cleans up in one step.
RUN apk add --no-cache \
    bash \
    build-base \
    python3-dev \
    py3-pip \
    espeak-ng

# 'build-base' is the Alpine equivalent of 'build-essential'
# 'py3-pip' ensures pip is available for the next step.
# python3-venv is usually included with python3-dev on Alpine

# Create and activate a virtual environment for Python packages
RUN python3 -m venv /opt/venv

# Install Python dependencies into the virtual environment
# We need to explicitly activate the venv for the RUN command to use it.
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
