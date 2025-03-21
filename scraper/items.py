# Define here the models for your scraped items
#
# See documentation in:
# https://docs.scrapy.org/en/latest/topics/items.html


from dataclasses import dataclass


@dataclass
class RagSourceItem:
    path: str
    text: str
    meta: dict
    bucket: str
