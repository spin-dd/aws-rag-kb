#!/usr/bin/env python
import click
from bedrag.aws import setup_boto3
from bedrag.utils import set_environ_from_tf
from bedrag.request import Query
import asyncio


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


if __name__ == "__main__":
    group()
