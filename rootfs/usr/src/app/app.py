# /custom_piper_uploader/rootfs/usr/src/app/app.py
import os
from flask import Flask, request, render_template, jsonify
from werkzeug.utils import secure_filename
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)

app = Flask(__name__)

# Configuration
UPLOAD_FOLDER = '/data/piper-models/'
ALLOWED_EXTENSIONS = {'onnx', 'json'}

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 200 * 1024 * 1024  # 200 MB max upload size

# Ensure the upload folder exists
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

def allowed_file(filename):
    """Check if the file has an allowed extension."""
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/', methods=['GET', 'POST'])
def upload_page():
    """Render the main upload page and handle file uploads."""
    if request.method == 'POST':
        # Check if the post request has the file part
        if 'onnx_file' not in request.files or 'json_file' not in request.files:
            logging.error("File part missing from request")
            return jsonify(status="error", message="Missing file part"), 400

        onnx_file = request.files['onnx_file']
        json_file = request.files['json_file']

        # Basic validation
        if onnx_file.filename == '' or json_file.filename == '':
            logging.error("No file selected")
            return jsonify(status="error", message="No selected file"), 400

        if not allowed_file(onnx_file.filename) or not allowed_file(json_file.filename):
            logging.error(f"Invalid file type: {onnx_file.filename}, {json_file.filename}")
            return jsonify(status="error", message="Invalid file type. Use .onnx and .json"), 400

        # Secure filenames
        onnx_filename = secure_filename(onnx_file.filename)
        json_filename = secure_filename(json_file.filename)
        
        logging.info("Clearing old model files from %s", app.config['UPLOAD_FOLDER'])
        # Clear out any old model files before saving new ones
        for f in os.listdir(app.config['UPLOAD_FOLDER']):
            os.remove(os.path.join(app.config['UPLOAD_FOLDER'], f))
            
        try:
            # Save files
            onnx_path = os.path.join(app.config['UPLOAD_FOLDER'], onnx_filename)
            json_path = os.path.join(app.config['UPLOAD_FOLDER'], json_filename)
            
            onnx_file.save(onnx_path)
            json_file.save(json_path)
            
            # Check if files are empty
            if os.path.getsize(onnx_path) == 0 or os.path.getsize(json_path) == 0:
                os.remove(onnx_path)
                os.remove(json_path)
                logging.error("Uploaded files are empty.")
                return jsonify(status="error", message="Uploaded files cannot be empty."), 400

            logging.info("Successfully uploaded %s and %s.", onnx_filename, json_filename)
            return jsonify(
                status="success",
                message=f"Success! {onnx_filename} and {json_filename} uploaded. The add-on will now load the new voice. Monitor the logs."
            )
        except Exception as e:
            logging.error(f"An error occurred during file save: {str(e)}")
            return jsonify(status="error", message=f"An error occurred: {str(e)}"), 500

    return render_template('index.html')

if __name__ == '__main__':
    # Use '0.0.0.0' to be accessible from outside the container
    app.run(host='0.0.0.0', port=5000, debug=False)