# aws-rag-kb

RAG with AWS Bedrock KnowlegeBase

## tofu

### .env

- AWS のクレデンシャルなどを設定

### バックエンドステート管理

```bash
docker compose run --rm tool tofu -chdir=tofu/admin init
docker compose run --rm tool tofu -chdir=tofu/admin plan -out admin.plan
docker compose run --rm tool tofu -chdir=tofu/admin apply admin.plan
```

### RAG リソース

```bash
docker compose run --rm tool tofu -chdir=tofu/rag init
docker compose run --rm tool tofu -chdir=tofu/rag plan -out rag.plan
docker compose run --rm tool tofu -chdir=tofu/rag apply rag.plan

```

### データベース

```bash
docker compose run --rm tool bin/aurora.py -to .secrets/rag.json create-schema
docker compose run --rm tool bin/aurora.py -to .secrets/rag.json create-role
```

### 構成出力

```bash
docker compose run --rm tool tofu -chdir=tofu/rag output -json > .secrets/rag.json
```

## データソース

### スクレーピング

```bash
docker compose run --rm tool scrapy crawl ncacfaq -a aws=.secrets/rag.json
```
