#!/usr/bin/with-contenv bashio
# /custom_piper_uploader/run.sh

# Define the python executable from our virtual environment
VENV_PYTHON="/opt/venv/bin/python3"

# Create directory for models if it doesn't exist
MODEL_DIR="/data/piper-models"
mkdir -p "${MODEL_DIR}"

bashio::log.info "Starting the Flask web server for file uploads..."
# Start the Flask app using the venv's python
"${VENV_PYTHON}" /usr/src/app/app.py &

# Wait for a model to be uploaded
while true; do
    ONNX_FILE=$(find "${MODEL_DIR}" -name "*.onnx" -print -quit)
    JSON_FILE=$(find "${MODEL_DIR}" -name "*.json" -print -quit)

    if [[ -f "${ONNX_FILE}" && -f "${JSON_FILE}" ]]; then
        bashio::log.info "Found custom voice model!"
        bashio::log.info "ONNX: ${ONNX_FILE}"
        bashio::log.info "JSON: ${JSON_FILE}"
        break
    else
        bashio::log.warning "No custom voice model found in ${MODEL_DIR}."
        bashio::log.warning "Please upload your .onnx and .json files via the Web UI."
        sleep 30
    fi
done

bashio::log.info "Starting Piper with the custom voice..."

# The PATH is already set up inside the venv, so we can call piper directly
# using the venv's python executable.
exec "${VENV_PYTHON}" -m wyoming_piper \
    --voice "${ONNX_FILE}" \
    --uri "tcp://0.0.0.0:10200"
