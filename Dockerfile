# /custom_piper_uploader/Dockerfile

# =====================================================================
# Stage 1: The Builder
# VERSION-AGNOSTIC CHANGE #1: Use 'latest' to always get the most
# up-to-date version of the piper image, avoiding manifest errors.
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

# VERSION-AGNOSTIC CHANGE #2: Use a wildcard (*) in the path.
# This will match /usr/local/lib/python3.9, /usr/local/lib/python3.11,
# or whatever Python version is used in the 'latest' builder image.
ENV PYTHON_PACKAGES_PATH=/usr/local/lib/python3*/site-packages

# Copy the installed python packages and executables
# from the dynamically-found locations in the builder stage.
COPY --from=builder ${PYTHON_PACKAGES_PATH} ${PYTHON_PACKAGES_PATH}
COPY --from=builder /usr/local/bin/ /usr/local/bin/

# Install flask for our web UI
RUN pip3 install --no-cache-dir flask

# Copy our own add-on files
COPY rootfs/ /

# Make our run script executable
RUN chmod +x /run.sh

CMD [ "/run.sh" ]
