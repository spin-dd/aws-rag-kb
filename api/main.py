import logging
import os

from fastapi import FastAPI, Request
from fastapi.responses import StreamingResponse
from bedrag.aws import setup_boto3

from bedrag.request import Query

logger = logging.getLogger()
logger.setLevel(level=logging.DEBUG) 


app = FastAPI()

@app.on_event("startup")
async def on_startup():
    for key in ["AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY", "AWS_REGION"]:
        conf_key = f"CONF_{key}"
        if conf_key in os.environ:
            os.environ[key] = os.environ[conf_key]
    setup_boto3()


def response(request: Request, query: Query) -> StreamingResponse:
    prompt_name = os.environ["PROMPT_SMITH_NAME"]
    return StreamingResponse(content=query.get_answer(prompt_name), media_type="text/event-stream")


def response_sync(request: Request, query: Query) -> dict:
    try:
        prompt_name = os.environ["PROMPT_SMITH_NAME"]

        answer = query.get_answer_sync(prompt_name)

        return dict(
            question=query.question,
            answer=answer,
        )

    except Exception as e:
        return {
            "error": str(e),
        }


@app.get("/faq_stream")
async def faq_stream_get(request: Request, q: str, d: str = None, c: str = None):
    query = Query(question=q, document=d, doc_class=c)
    return response(request, query)


@app.post("/faq_stream")
async def kb_stream_post(request: Request, query: Query):
    return response(request, query)


@app.get("/faq")
def kb_get(request: Request, q: str, d: str = None, c: str = None):
    query = Query(question=q, document=d, doc_class=c)
    return response_sync(request, query)


@app.post("/faq")
def kb_post(request: Request, query: Query):
    return response_sync(request, query)
