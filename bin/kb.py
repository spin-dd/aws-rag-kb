#!/usr/bin/env python
import json
import os
import boto3
import click
from bedrag.aws import setup_boto3
from bedrag.utils import set_environ_from_tf
import time
from fastapi.encoders import jsonable_encoder


@click.group()
@click.option("--tf_output", "-to", default=None)
@click.pass_context
def group(ctx, tf_output):
    ctx.ensure_object(dict)

    set_environ_from_tf(tf_output)
    setup_boto3()


@group.command()
@click.pass_context
def sync(ctx):
    """同期"""
    # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/bedrock-agent.html

    client = boto3.client("bedrock-agent")
    # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/bedrock-agent/client/start_ingestion_job.html
    res = client.start_ingestion_job(
        dataSourceId=os.environ["BEDROCK_DS_ID"],
        knowledgeBaseId=os.environ["BEDROCK_KB_ID"],
    )

    job = res["ingestionJob"]
    jobid = job["ingestionJobId"]
    status = job["status"]
    while status in ["IN_PROGRESS", "STARTING"]:
        time.sleep(2)
        # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/bedrock-agent/client/get_ingestion_job.html
        res = client.get_ingestion_job(
            dataSourceId=os.environ["BEDROCK_DS_ID"],
            knowledgeBaseId=os.environ["BEDROCK_KB_ID"],
            ingestionJobId=jobid,
        )
        status = res["ingestionJob"]["status"]

    print(json.dumps(jsonable_encoder(res), indent=2))


if __name__ == "__main__":
    group()
