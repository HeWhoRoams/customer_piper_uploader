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

# THE VERIFIED FIX: The builder image installs packages to the global
# system path for Python 3.9. This is the correct path.
ENV PYTHON_PACKAGES_PATH=/usr/lib/python3.9/site-packages
ENV PYTHON_BIN_PATH=/usr/local/bin/

# Copy the installed python packages and executables from the
# verified locations in the builder stage to the final system path.
COPY --from=builder ${PYTHON_PACKAGES_PATH} ${PYTHON_PACKAGES_PATH}
COPY --from=builder ${PYTHON_BIN_PATH} ${PYTHON_BIN_PATH}

# Install flask for our web UI
RUN pip3 install --no-cache-dir flask

# Copy our own add-on files
COPY rootfs/ /

# Make our run script executable
RUN chmod +x /run.sh

CMD [ "/run.sh" ]
