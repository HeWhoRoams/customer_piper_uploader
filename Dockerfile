# /custom_piper_uploader/Dockerfile

# =====================================================================
# Stage 1: The Builder
# We use the official, pre-built wyoming-piper image. It contains all
# the compiled files we need, saving us from the errors.
# =====================================================================
FROM rhasspy/wyoming-piper:latest as builder

# =====================================================================
# Stage 2: The Final Add-on
# We start from the standard Home Assistant base image, as required.
# =====================================================================
ARG BUILD_FROM
FROM homeassistant/amd64-base-debian:bullseye

# Install only the absolute minimum RUNTIME dependencies.
# No -dev, no build-essential, no cmake needed!
RUN apt-get update && apt-get install -y --no-install-recommends \
    espeak-ng \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# The key step: Copy the entire pre-compiled Virtual Environment
# from the 'builder' stage into our final image. This contains
# a working python, piper, onnxruntime, etc.
COPY --from=builder /opt/venv /opt/venv

# Our add-on also needs the 'flask' library for the web UI.
# Let's install it into the virtual environment we just copied.
RUN . /opt/venv/bin/activate && \
    pip install --no-cache-dir flask

# Copy our own add-on files (web server, run script)
COPY rootfs/ /

# Make our run script executable
RUN chmod +x /run.sh

CMD [ "/run.sh" ]
