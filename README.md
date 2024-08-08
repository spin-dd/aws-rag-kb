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

ECR:

```bash
docker compose run --rm tool tofu -chdir=tofu/rag plan -out rag.plan -target=module.ecr
docker compose run --rm tool tofu -chdir=tofu/rag apply rag.plan
docker compose run --rm tool tofu -chdir=tofu/rag output -json > .secrets/rag.json

```

API Gateway:

```bash
docker compose run --rm tool tofu -chdir=tofu/rag plan -out rag.plan -target=module.apigw
docker compose run --rm tool tofu -chdir=tofu/rag apply rag.plan
docker compose run --rm tool tofu -chdir=tofu/rag output -json > .secrets/rag.json
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

### 同期

```bash
docker compose run --rm tool bin/kb.py -to .secrets/rag.json sync
```

## テスト

```bash
docker compose run --rm tool bin/rag.py -to .secrets/rag.json query 地震で壊れた屋根を訪問した業者に応急処置の依頼をしたら高額請求されてしまいました。 -s hdknr/faq
docker compose run --rm tool bin/rag.py -to .secrets/rag.json query "ふるさと納税をキャンセルしたいです" -s hdknr/faq
docker compose run --rm tool bin/rag.py -to .secrets/rag.json query "チケット転売で購入したのだがチケットが届きません" -s hdknr/faq
```

### API

```bash
docker compose run --rm tool bin/rag.py -to .secrets/rag.json api "チケット転売で購入したのだがチケットが届きません"
```
