# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://docs.scrapy.org/en/latest/topics/item-pipeline.html


# useful for handling different item types with a single interface
# from itemadapter import ItemAdapter

from bedrag.s3 import put_text
from .items import RagSourceItem


class RagSoourcePipeline:
    def process_item(self, item: RagSourceItem, spider):
        put_text(item.text, item.bucket, item.path)
        put_text(item.meta, item.bucket, item.path + ".json")
        return item
