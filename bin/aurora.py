#!/usr/bin/env python
import json
import os
import re
import boto3
import click
from pydantic import BaseModel
from bedrag.models import Knowlege
from sqlalchemy import create_engine
from sqlalchemy.schema import CreateTable


def setup_boto3():
    keys = {
        "profile_name": "AWS_PROFILE",
        "region_name": "AWS_REGION",
        "aws_access_key_id": "AWS_ACCESS_KEY_ID",
        "aws_secret_access_key": "AWS_SECRET_ACCESS_KEY",
    }
    params = dict((k, os.environ[v]) for k, v in keys.items() if v in os.environ)
    boto3.setup_default_session(**params)


def get_sm_clinet():
    # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/secretsmanager.html
    return boto3.client("secretsmanager")


def get_rds_ds_client():
    # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/rds-data.html
    return boto3.client("rds-data")


def get_rds_clint():
    # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/rds.html
    return boto3.client("rds")


def get_secret_arn(name):
    # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/secretsmanager/client/list_secrets.html
    client = get_sm_clinet()
    values = client.list_secrets(Filters=[dict(Key="name", Values=[name])])["SecretList"]
    if len(values) == 1:
        return values[0]["ARN"]
    return


def get_secret_value(id, is_json=True):
    # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/secretsmanager/client/get_secret_value.html
    if not id.startswith("arn"):
        id = get_secret_arn(id)

    if not id:
        return

    client = get_sm_clinet()
    value = client.get_secret_value(SecretId=id)["SecretString"]
    if is_json and value:
        return json.loads(value)
    return value


def get_rds_cluster_arn(identfire):
    client = get_rds_clint()
    # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/rds/client/describe_db_clusters.html
    values = client.describe_db_clusters(DBClusterIdentifier=os.environ["KB_DATABASE_CLUSTER"])["DBClusters"]
    if len(values) == 1:
        return values[0]["DBClusterArn"]


class Aurora(BaseModel):
    cluster_arn: str
    secret_arn: str
    database: str

    def execute(self, sql):
        # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/rds-data/client/execute_statement.html

        if not self.cluster_arn.startswith("arn"):
            clusterArn = get_rds_cluster_arn(self.cluster_arn)
            if not clusterArn:
                return {"failed": "no clusterArn"}
        else:
            clusterArn = self.cluster_arn

        if not self.secret_arn.startswith("arn"):
            secretArn = get_secret_arn(self.secret_arn)
            if not secretArn:
                return {"failed": "no secretArn"}
        else:
            secretArn = self.secret_arn

        client = get_rds_ds_client()
        return client.execute_statement(resourceArn=clusterArn, secretArn=secretArn, sql=sql, database=self.database)


def create_table_ddl():
    engine = create_engine("postgresql://")

    tables = map(
        lambda t: str(CreateTable(t).compile(engine)),
        Knowlege.metadata.tables.values(),
    )
    return "\n".join(list(tables))


@click.group()
@click.option("--tf_output", "-to", default=None)
@click.pass_context
def group(ctx, tf_output):
    ctx.ensure_object(dict)

    if tf_output:
        for key, value in json.load(open(tf_output)).items():
            os.environ[key] = value["value"]

    setup_boto3()

    ma = re.search(
        "^(?P<db>[^\\.]+).(?P<schema>[^\\.]+).(?P<table>[^\\.]+)$",
        os.environ.get("TF_VAR_database_table_name", ""),
    )
    if ma:
        ctx.obj["database_table_name"] = ma.groupdict()

    ma = re.search(
        "^(?P<username>[^.]+)\\s(?P<password>[^.]+)$",
        os.environ.get("TF_VAR_database_table_name", ""),
    )
    if ma:
        ctx.obj["database_master_user"] = ma.groupdict()

    ctx.obj["aurora"] = Aurora(
        cluster_arn=os.environ["AURORA_CLUSTER_ARN"],
        secret_arn=os.environ["AURORA_MASTER_USER_SECERT_ARN"],
        database=ctx.obj["database_table_name"]["db"],
    )


@group.command()
@click.pass_context
def setup_vector(ctx):
    """vector(pgVextro) の設定"""
    aurora: Aurora = ctx.obj["aurora"]
    sql = """CREATE EXTENSION IF NOT EXISTS vector;"""
    res = aurora.execute(sql)
    print(json.dumps(res, indent=2))


@group.command()
@click.pass_context
def create_schema(ctx):
    """スキーマ作成"""
    aurora: Aurora = ctx.obj["aurora"]
    params = ctx.obj["database_table_name"]
    sql = """CREATE SCHEMA {schema};""".format(**params)
    res = aurora.execute(sql)

    print(json.dumps(res, indent=2))


@group.command()
@click.pass_context
def create_role(ctx):
    """ロール(アクセスユーザー)作成"""
    aurora: Aurora = ctx.obj["aurora"]
    value = get_secret_value(os.environ["AURORA_USER_SECERT_ARN"])

    sql = """CREATE ROLE {username} WITH PASSWORD '{password}' LOGIN;""".format(**value)
    res = aurora.execute(sql)

    print(json.dumps(res, indent=2))


@group.command()
@click.pass_context
def create_table(ctx):
    """KBテーブル作成"""
    aurora: Aurora = ctx.obj["aurora"]
    sql = create_table_ddl()
    res = aurora.execute(sql)
    print(json.dumps(res, indent=2))


@group.command()
@click.pass_context
def create_vector_index(ctx):
    """ベクトルフィールドにインデックス作成"""
    aurora: Aurora = ctx.obj["aurora"]
    field = Knowlege.get_vector_field()
    params = ctx.obj["database_table_name"]
    params["field"] = field.name
    sql = "CREATE INDEX on {schema}.{table} USING hnsw ({field} vector_cosine_ops);".format(**params)
    res = aurora.execute(sql)
    print(json.dumps(res, indent=2))


@group.command()
@click.pass_context
def grant_schema(ctx):
    """スキーマに許可"""
    aurora: Aurora = ctx.obj["aurora"]
    value = get_secret_value(os.environ["AURORA_USER_SECERT_ARN"])
    table_names = ctx.obj["database_table_name"]
    sql = """GRANT ALL ON SCHEMA {schema} to {username};""".format(**table_names, **value)
    res = aurora.execute(sql)
    print(json.dumps(res, indent=2))


@group.command()
@click.pass_context
def grant_table(ctx):
    """テーブルに許可"""
    aurora: Aurora = ctx.obj["aurora"]
    value = get_secret_value(os.environ["AURORA_USER_SECERT_ARN"])
    table_names = ctx.obj["database_table_name"]
    sql = """GRANT ALL ON TABLE {schema}.{table} to {username};""".format(
        **table_names,
        **value,
    )
    res = aurora.execute(sql)
    print(json.dumps(res, indent=2))


if __name__ == "__main__":
    group()
