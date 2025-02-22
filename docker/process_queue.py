from flask import Flask, request, render_template
from azure.storage.blob import BlobServiceClient
from azure.storage.queue import QueueClient

# Initialize the Flask application
app = Flask(__name__)

# Azure Storage account and container details
STORAGE_ACCOUNT_NAME = "myverybigfinalstorage"  # Name of the Azure Storage account
STORAGE_CONTAINER_NAME = "input-images"  # Container where images will be stored
QUEUE_NAME = "image-processing-queue"  # Queue name for processing tasks

# Initialize Azure Blob Service Client to interact with Blob Storage
blob_service_client = BlobServiceClient(account_url=f"https://{STORAGE_ACCOUNT_NAME}.blob.core.windows.net")

# Initialize Azure Queue Client to interact with the message queue
queue_client = QueueClient.from_connection_string(
    f"DefaultEndpointsProtocol=https;AccountName={STORAGE_ACCOUNT_NAME};EndpointSuffix=core.windows.net",
    QUEUE_NAME
)

@app.route("/", methods=["GET", "POST"])
def upload_file():
    if request.method == "POST":
        file = request.files["file"]  # Get the uploaded file
        if file:
            # Create a blob client for the uploaded file
            blob_client = blob_service_client.get_blob_client(container=STORAGE_CONTAINER_NAME, blob=file.filename)
            # Upload the file to Azure Blob Storage (overwrite if it exists)
            blob_client.upload_blob(file.read(), overwrite=True)
            # Send a message to the queue with the filename
            queue_client.send_message(file.filename)
            return "File uploaded to Azure Blob Storage and added to queue!"
    
    # Render the HTML form for file upload
    return render_template("index.html")

if __name__ == "__main__":
    # Start the Flask application in debug mode on all available interfaces at port 5000
    app.run(debug=True, host="0.0.0.0", port=5000)
