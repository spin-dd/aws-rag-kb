import os

import boto3
from langchain import hub

from langchain_aws.chat_models import ChatBedrock
from langchain_aws.retrievers import AmazonKnowledgeBasesRetriever


boto3.set_stream_logger()


def create_llm(bedrock_client=None, model_version_id=None, region_name=None):
    bedrock_client = bedrock_client or boto3.client("bedrock-runtime")
    model_version_id = model_version_id or os.environ["BEDROCK_LLM_MODEL_ID"]
    bedrock_llm = ChatBedrock(model_id=model_version_id, client=bedrock_client, model_kwargs={"temperature": 0})
    return bedrock_llm


def create_retriever(knowledge_base_id=None, client=None, retrieval_config=None, **kwargs):
    # https://api.python.langchain.com/en/latest/retrievers/langchain_community.retrievers.bedrock.AmazonKnowledgeBasesRetriever.html
    knowledge_base_id = knowledge_base_id or os.environ["BEDROCK_KB_ID"]

    # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/bedrock-agent-runtime.html
    client = client or boto3.client("bedrock-agent-runtime")
    retrieval_config = retrieval_config or create_retrieval_config()
    retriever = AmazonKnowledgeBasesRetriever(
        knowledge_base_id=knowledge_base_id,
        retrieval_config=retrieval_config,
        client=client,
    )
    return retriever


def create_retrieval_config(numberOfResults=4, filter=None):
    # https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/bedrock-agent-runtime/client/retrieve.html
    res = dict(numberOfResults=numberOfResults)
    if filter:
        res["filter"] = filter
    return dict(vectorSearchConfiguration=res)


def prompt_from_smith(smith_name):
    return hub.pull(smith_name, api_url="https://api.hub.langchain.com")
