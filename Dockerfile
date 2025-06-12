# /custom_piper_uploader/Dockerfile

# =====================================================================
# Stage 1: The Builder
# =====================================================================
FROM rhasspy/wyoming-piper:latest as builder

# =====================================================================
# Stage 2: The Final Add-on
# =====================================================================
ARG BUILD_FROM
FROM homeassistant/amd64-base-debian:bullseye

# Install minimum runtime dependencies + pip (for Flask)
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    espeak-ng \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# THE DEFINITIVE FIX: Based on the 5 Whys analysis, this is the correct
# path for packages installed by the non-root 'piper' user inside the
# builder image. The wildcard (*) makes it future-proof.
ENV PYTHON_PACKAGES_PATH=/home/piper/.local/lib/python3*/site-packages

# Copy the installed python packages and executables from the
# verified locations in the builder stage.
COPY --from=builder ${PYTHON_PACKAGES_PATH} /usr/local/lib/python3.9/site-packages
COPY --from=builder /home/piper/.local/bin/ /usr/local/bin/

# Install flask for our web UI
RUN pip3 install --no-cache-dir flask

# Copy our own add-on files
COPY rootfs/ /

# Make our run script executable
RUN chmod +x /run.sh

CMD [ "/run.sh" ]
