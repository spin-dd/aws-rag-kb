import boto3
import os


def setup_boto3():
    """ 環境変数より boto3にクレデンシャル情報を設定する"""
    keys = {
        "profile_name": "AWS_PROFILE",
        "region_name": "AWS_REGION",
        "aws_access_key_id": "AWS_ACCESS_KEY_ID",
        "aws_secret_access_key": "AWS_SECRET_ACCESS_KEY",
    }
    params = dict((k, os.environ[v]) for k, v in keys.items() if v in os.environ)
    boto3.setup_default_session(**params)
