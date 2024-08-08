#!/usr/bin/env python
import asyncio
import os
import click
from bedrag.aws import setup_boto3
from bedrag.utils import set_environ_from_tf
from bedrag.request import Query
from urllib.parse import urlencode
import requests
from datetime import datetime
import json


@click.group()
@click.option("--tf_output", "-to", default=None)
@click.pass_context
def group(ctx, tf_output):
    ctx.ensure_object(dict)

    set_environ_from_tf(tf_output)
    setup_boto3()


@group.command()
@click.argument("question")
@click.option("--smith_name", "-s", default=None)
@click.option("--document", "-d", default=None)
@click.option("--doc_class", "-dc", default=None)
@click.pass_context
def query(ctx, question, smith_name, document, doc_class):
    """問い合わせ"""

    query = Query(
        question=question,
        doc_class=doc_class,
        document=document,
    )
    res = query.get_answer_sync(smith_name)
    print(res)


@group.command()
@click.argument("question")
@click.option("--smith_name", "-s", default=None)
@click.option("--document", "-d", default=None)
@click.option("--doc_class", "-dc", default=None)
@click.pass_context
def query_stream(ctx, question, smith_name, document, doc_class):
    """問い合わせ(ストリーミング)"""

    query = Query(
        question=question,
        doc_class=doc_class,
        document=document,
    )

    async def async_wrap():
        res = ""
        async for value in query.get_answer(smith_name):
            res += value
            print(value, end="")

    asyncio.run(async_wrap())


@group.command()
@click.argument("question")
@click.option("--document", "-d", default=None)
@click.option("--doc_class", "-dc", default=None)
@click.option("--streaming", "-s", is_flag=True)
@click.pass_context
def api(ctx, question, document, doc_class, streaming):
    """問い合わせAPI"""

    def handle_sse_event(line):
        if not line:
            return
        dt = datetime.now()
        event_data = line.decode("utf-8")
        print(f"{dt}: {event_data}")

    host = os.environ["API_DOMAIN_NAME"]
    endpoint = f"https://{host}/faq"
    if streaming:
        endpoint += "_stream"

    params = dict((k, v) for k, v in dict(q=question, d=document, c=doc_class).items() if v)
    url = endpoint + "?" + urlencode(params)

    # https://requests.readthedocs.io/en/latest/user/advanced/#body-content-workflow
    response = requests.get(url, stream=streaming)
    if response.headers["Content-Type"].startswith("application/json"):
        print(json.dumps(response.json(), ensure_ascii=False, indent=2))
    elif response.headers["Content-Type"].startswith("text/event-stream"):
        list(map(handle_sse_event, response.iter_lines()))


if __name__ == "__main__":
    group()
