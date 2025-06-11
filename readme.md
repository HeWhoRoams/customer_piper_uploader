# /custom_piper_uploader/README.md
# Home Assistant Add-on: Custom Piper Voice Uploader

This add-on allows you to upload your own custom-trained Piper voice models (`.onnx` and `.json` files) to Home Assistant and use them as a Text-to-Speech (TTS) engine via the Wyoming protocol.

## Features

-   **Web UI for Uploads**: Simple web interface accessible via Ingress to upload your voice files.
-   **Persistent Storage**: Models are stored in the `/data` directory, so they persist across add-on restarts.
-   **Automatic Restart**: The add-on automatically detects new models and restarts the Piper service to use them.
-   **Wyoming Integration**: Exposes the Piper TTS service over TCP port 10200 for seamless integration with Home Assistant.

## Installation

1.  **Add the Repository**:
    * Navigate to **Settings > Add-ons > Add-on Store**.
    * Click the three-dots menu in the top right and select **Repositories**.
    * Add the URL of your repository containing this add-on and click **Add**.

2.  **Install the Add-on**:
    * Find the "Custom Piper Voice Uploader" add-on in the store and click on it.
    * Click **Install** and wait for the process to complete.

## How to Use

1.  **Start the Add-on**:
    * After installation, go to the add-on's page and click **Start**.
    * Check the **Logs** tab to see the startup progress. The add-on will initially report that no model was found.

2.  **Upload Your Voice Model**:
    * Click the **Open Web UI** button on the add-on's page.
    * Use the file input fields to select your `.onnx` model file and the corresponding `.json` configuration file.
    * Click **Upload Voice Model**.
    * You will see a success message. The add-on will automatically detect the new files and restart the Piper service in the background to load your new voice. You can monitor the progress in the **Logs** tab.

3.  **Configure Home Assistant**:
    * Go to **Settings > Devices & Services**.
    * If a "Piper" integration has not been automatically discovered, click **Add Integration** and search for **Wyoming**.
    * For the server address, enter the IP address of your Home Assistant device (e.g., `192.168.1.123`). You can also use `core-ssh.local.hass.io` if you have the SSH add-on, or find the IP in **Settings > System > Network**.
    * For the port, enter `10200`.
    * Home Assistant will connect to the add-on, and your custom voice will be available as a TTS service.

## Troubleshooting

* **"No custom voice model found"**: This log message is normal on the first start. Use the Web UI to upload your model files.
* **"Error: Invalid file type"**: Ensure you are uploading one `.onnx` file and one `.json` file.
* **Add-on doesn't start the Piper service**: Check the logs for errors. The most common issue is a missing or corrupted model file. Try re-uploading your files.
* **Cannot connect from Wyoming integration**: Ensure the add-on is running and that you are using the correct Home Assistant IP address and port (`10200`).