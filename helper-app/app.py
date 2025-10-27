import os
from flask import Flask, render_template, jsonify
import boto3
from botocore.client import Config

app = Flask(__name__)

COS_BUCKET = os.environ.get("COS_BUCKET", "")
REGION = os.environ.get("REGION", "")

COS_ACCESS_KEY_ID = os.environ.get("COS_ACCESS_KEY_ID", "")
COS_SECRET_ACCESS_KEY = os.environ.get("COS_SECRET_ACCESS_KEY", "")

cos = boto3.client(
    "s3",
    aws_access_key_id=COS_ACCESS_KEY_ID,
    aws_secret_access_key=COS_SECRET_ACCESS_KEY,
    config=Config(signature_version="s3v4"),
    endpoint_url=f"https://s3.{REGION}.cloud-object-storage.appdomain.cloud"
)

def bucket_console_url():
    return f"https://cloud.ibm.com/objectstorage/buckets?bucket={COS_BUCKET}"

def list_csvs():
    try:
        resp = cos.list_objects_v2(Bucket=COS_BUCKET)
        contents = resp.get("Contents", []) or []
        return [o["Key"] for o in contents if o["Key"].lower().endswith(".csv")]
    except Exception:
        return []

@app.route("/")
def index():
    files = list_csvs()
    return render_template(
        "index.html",
        bucket=COS_BUCKET,
        region=REGION,
        files=files,
        bucket_console_url=bucket_console_url()
    )

@app.route("/api/files")
def api_files():
    return jsonify(list_csvs())

@app.route("/api/file/<key>")
def api_file(key):
    try:
        obj = cos.get_object(Bucket=COS_BUCKET, Key=key)
        return obj["Body"].read().decode("utf-8")
    except Exception as e:
        return jsonify({"error": str(e)}), 404

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
