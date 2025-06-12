# /custom_piper_uploader/Dockerfile

# =====================================================================
# Stage 1: The Builder
# Use a specific, stable version of the official piper image.
# =====================================================================
FROM rhasspy/wyoming-piper:1.5.2 as builder

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

# The piper image uses Python 3.11. The packages are here:
ENV PYTHON_PACKAGES_PATH=/usr/local/lib/python3.11/site-packages

# The key fix: Copy the installed python packages and executables
# from the correct locations in the builder stage.
COPY --from=builder ${PYTHON_PACKAGES_PATH} ${PYTHON_PACKAGES_PATH}
COPY --from=builder /usr/local/bin/ /usr/local/bin/

# Install flask for our web UI
RUN pip3 install --no-cache-dir flask

# Copy our own add-on files
COPY rootfs/ /

# Make our run script executable
RUN chmod +x /run.sh

CMD [ "/run.sh" ]
