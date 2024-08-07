from typing import Union

from pydantic import BaseModel

from .rag import get_answer, get_answer_stream


class Query(BaseModel):
    question: str
    document: Union[str, None] = None
    doc_class: Union[str, None] = None

    def get_answer(self, prompt_name):
        return get_answer_stream(prompt_name, self.question, document=self.document, doc_class=self.doc_class)

    def get_answer_sync(self, prompt_name):
        return get_answer(prompt_name, self.question, document=self.document, doc_class=self.doc_class)
