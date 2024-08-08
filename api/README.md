# API

- Lambda Function で実行させる
- Lmabda Web Adapter をつかってストリーミングで返せるようにする

## ビルド

```bash
./api/bin/login.sh .secrets/rag.json
./api/bin/build.sh .secrets/rag.json
./api/bin/push.sh .secrets/rag.json
```
