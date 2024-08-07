import os
from operator import itemgetter
from langchain.chains import RetrievalQA
from langchain.prompts.chat import ChatPromptTemplate
from typing import AsyncIterable
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnablePassthrough, RunnableParallel
from .kb import create_llm, create_retrieval_config, create_retriever, prompt_from_smith


def get_prompt(smith_name=None):
    """プロンプトを返す"""
    if smith_name:
        return prompt_from_smith(smith_name)

    prompt = ChatPromptTemplate.from_messages(
        [
            (
                "system",
                (
                    "あなたは優秀なヘルプデスクの担当者です。"
                    "\nお客様からの問い合わせに対して、過去の対応履歴を参考にして、問題の解決案を提案してください。"
                ),
            ),
            ("user", "{context}\n質問{question} どうしたらいいでしょうか ?個人名を伏せて回答してください。\n返答:"),
        ]
    )
    return prompt


def get_answer(prompt_smith_name, query, **meta_query) -> str:
    """同期返答"""
    keys = ["document", "doc_class"]
    prompt = get_prompt(smith_name=prompt_smith_name)

    llm = create_llm(model_version_id=os.environ["BEDROCK_LLM_MODEL_ID"], region_name=os.environ["AWS_REGION"])

    conds = [dict(equals=dict(key=k, value=v)) for k, v in meta_query.items() if k in keys and v]
    retrieval_config = None
    if len(conds) > 1:
        retrieval_config = create_retrieval_config(filter=dict(andAll=conds))
    elif len(conds) == 1:
        retrieval_config = create_retrieval_config(filter=conds[0])

    retriever = create_retriever(knowledge_base_id=os.environ["BEDROCK_KB_ID"], retrieval_config=retrieval_config)

    qa = RetrievalQA.from_chain_type(
        llm=llm, retriever=retriever, return_source_documents=True, chain_type_kwargs={"prompt": prompt}
    )

    response = qa.invoke({"query": query})

    query = response.get("query", None)
    result = response.get("result", None)
    # source = "\n".join(map(lambda d: d.page_content, response.get("source_documents", [])))
    return result


async def get_answer_stream(prompt_smith_name, query, **meta_query) -> AsyncIterable[str]:
    """非同期回答(ストリーミング返答)"""
    keys = ["document", "doc_class"]
    prompt = get_prompt(smith_name=prompt_smith_name)

    llm = create_llm(model_version_id=os.environ["BEDROCK_LLM_MODEL_ID"], region_name=os.environ["AWS_REGION"])

    conds = [dict(equals=dict(key=k, value=v)) for k, v in meta_query.items() if k in keys and v]
    retrieval_config = None
    if len(conds) > 1:
        retrieval_config = create_retrieval_config(filter=dict(andAll=conds))
    elif len(conds) == 1:
        retrieval_config = create_retrieval_config(filter=conds[0])

    retriever = create_retriever(knowledge_base_id=os.environ["BEDROCK_KB_ID"], retrieval_config=retrieval_config)

    output_parser = StrOutputParser()  # 応答の文字烈化

    chain = (
        RunnableParallel({"context": itemgetter("query") | retriever, "question": RunnablePassthrough()})
        | prompt
        | llm
        | output_parser
    )
    res = chain.astream({"query": query})

    async for msg in res:
        yield msg
