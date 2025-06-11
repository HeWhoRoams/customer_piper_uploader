#!/usr/bin/with-contenv bashio
# /custom_piper_uploader/run.sh

# Create directory for models if it doesn't exist
MODEL_DIR="/data/piper-models"
mkdir -p "${MODEL_DIR}"

bashio::log.info "Starting the Flask web server for file uploads..."
# Start the Flask app in the background to handle uploads
python3 /usr/src/app/app.py &

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

# Activate virtual environment
# S6-overlay with-contenv doesn't source profiles, so we need to set PATH manually
PATH="/opt/venv/bin:$PATH"

# Construct the Piper command
PIPER_COMMAND=(
    "python3"
    "-m"
    "wyoming_piper"
    "--voice"
    "${ONNX_FILE}"
    "--uri"
    "tcp://0.0.0.0:10200"
)

# Run Piper
exec "${PIPER_COMMAND[@]}"