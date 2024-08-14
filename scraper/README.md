# scraper

- scrapy のスパイダーで 独立行政法人国民生活センターの 消費者トラブル FAQ をスクレイピングする
- scrapy のパイプラインで、Bedrock Knowledge Base の S3 バケットに マークダウン形式で保存する。
- 同時に、対応するメタデータ JSON を S3 バケットに保存する

![](docs/scraper.drawio.png)

## ナレッジベース同期

```bash
docker compose run --rm tool bin/kb.py -to .secrets/rag.json sync
```
