import scrapy
from ..items import RagSourceItem
import markdownify
from urllib.parse import urlparse
import re
import json
from pathlib import Path


class NcacFaqSpider(scrapy.Spider):
    """
    国民生活センター: 消費者トラブルFAQ
    """

    name: str = "ncacfaq"
    allowed_domains = ["www.faq.kokusen.go.jp"]
    start_urls = [
        "https://www.faq.kokusen.go.jp/?site_domain=default",
    ]
    URL_RE = re.compile(r"^/faq/show/(?P<id>\d+)$")
    DOC_CLASS = "国民生活センター"
    DOCUMENT = "消費者トラブルFAQ"

    def __init__(self, aws=None, pages=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        aws_info = aws and Path(aws)
        if aws_info and aws_info.exists():
            self.aws_info = json.load(aws_info.open())


    def parse(self, response):
        anchors = response.css("a[href]")
        for anchor in anchors:
            url = anchor.attrib["href"]
            yield response.follow(url)

        url = urlparse(response.url)
        ma = self.URL_RE.search(url.path)
        if ma:
            faq_id = ma.groupdict()["id"]
            for item in response.css(".okw_main_faq"):
                html = item.extract()
                source = markdownify.markdownify(html, heading_style="ATX")  # markdown
                path = f"{self.DOC_CLASS}/{self.DOCUMENT}.{faq_id}.md"
                meta = dict(
                    doc_class=self.DOC_CLASS,
                    document=self.DOCUMENT,
                )
                bucket = self.aws_info and self.aws_info.get("DATASOURCE_BUCKET", {}).get("value", "")
                yield RagSourceItem(
                    text=source,
                    path=path,
                    meta=json.dumps(meta, ensure_ascii=False, indent=2),
                    bucket=bucket,
                )
