import pyzipper
import os
import base64
import shutil
import json


def decrypt_zip(event, context):
    print("Event", event)
    print("Context", context)

    # Parse body
    data = json.loads(event["body"])

    # Variables
    file_base64 = data["file"]
    file_name = data["file_name"]
    password = data["password"]

    # Decode base64 encoded zip file
    decoded_bytes = base64.b64decode(file_base64, altchars=b'+/')

    # Write decoded bytes to a zip file
    with open(f"/tmp/{file_name}_encrypted.zip", "wb") as f:
        f.write(decoded_bytes)
        f.close()

    # Decode and extract all files into a new folder
    folder_name = ""
    with pyzipper.AESZipFile(f"/tmp/{file_name}_encrypted.zip") as f:
        f.pwd = bytes(password, 'utf-8')
        f.extractall(f"/tmp/{file_name}")

        f.close()


    # Zip folder
    shutil.make_archive(f"/tmp/{file_name}", 'zip', f"/tmp/{file_name}")

    # Open zip file and encode it
    with open(f"/tmp/{file_name}.zip", "rb") as f:
        obase64_bytes = base64.b64encode(f.read(), altchars=b'+/')
        obase64 = obase64_bytes.decode("utf-8")
        f.close()

    body = {
        "file": obase64,
    }

    response = {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
        },
        "body": json.dumps(body),
        "isBase64Encoded": False
    }

    # Clean up
    os.system(f"rm -rf /tmp/{file_name}*")

    return response
