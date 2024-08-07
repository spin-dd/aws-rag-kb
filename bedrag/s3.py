import boto3
from io import BytesIO


def put_text(content, bucket, path):
    s3 = boto3.client("s3")
    s3.upload_fileobj(BytesIO(content.encode("utf8")), bucket, path)