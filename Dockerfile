# =====================================================================
# Stage 1: Home Assistant Base
# We use the standard HA base image just to grab the files we need
# to make our add-on compliant (S6 Overlay and bashio).
# =====================================================================
FROM homeassistant/amd64-base-debian:bullseye as ha_base

# =====================================================================
# Stage 2: The Final Add-on
# The KEY CHANGE: We start FROM the working piper image. This gives us
# a perfect environment where piper and all its dependencies work.
# =====================================================================
FROM rhasspy/wyoming-piper:latest

# Now, we add the Home Assistant components into the piper image.
# We copy the S6 overlay init system from our `ha_base` stage.
COPY --from=ha_base /etc/s6-overlay/ /etc/s6-overlay/
COPY --from=ha_base /usr/bin/s6-svscan /usr/bin/s6-svscan

# We also copy the bashio library for interacting with Home Assistant.
COPY --from=ha_base /usr/lib/bashio /usr/lib/bashio

# The piper image doesn't have `pip` readily available, so we
# install it, then use it to install `flask` for our web UI.
RUN apt-get update && apt-get install -y --no-install-recommends python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --no-cache-dir flask

# Finally, copy our own add-on files (the web server and run script)
COPY rootfs/ /

# Make our run script executable
RUN chmod +x /run.sh

# The CMD is now our run script, which will be managed by S6.
CMD [ "/run.sh" ]
