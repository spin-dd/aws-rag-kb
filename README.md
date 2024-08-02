# aws-rag-kb

RAG with AWS Bedrock KnowlegeBase

## tofu

.env の設定後、を設定する

```bash
docker compose run --rm opentofu -chdir=tofu/rag init
docker compose run --rm opentofu -chdir=tofu/rag plan -out rag.plan
docker compose run --rm opentofu -chdir=tofu/rag apply rag.plan

```
