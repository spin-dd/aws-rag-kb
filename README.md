# aws-rag-kb

RAG with AWS Bedrock KnowlegeBase

## tofu

### .env

- AWS のクレデンシャルなどを設定

### バックエンドステート管理

```bash
docker compose run --rm opentofu -chdir=tofu/admin init
docker compose run --rm opentofu -chdir=tofu/admin plan -out admin.plan
docker compose run --rm opentofu -chdir=tofu/admin apply admin.plan
```

### RAG リソース

```bash
docker compose run --rm opentofu -chdir=tofu/rag init
docker compose run --rm opentofu -chdir=tofu/rag plan -out rag.plan
docker compose run --rm opentofu -chdir=tofu/rag apply rag.plan

```
