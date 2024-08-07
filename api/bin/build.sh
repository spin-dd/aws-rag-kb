#!/bin/sh
if [ -f .env ]; then
    export $(cat .env|grep -v "^#"|xargs)
fi

export $(cat $1| jq -r 'to_entries | .[] | "\(.key)=\(.value.value)"')

#
DOCKERFILE=api/Dockerfile
REPO=${FUNCTION_ECR_KB}
#
CONTEXT_DIR=.
TAG=latest

docker build -t ${REPO} --no-cache -f ${DOCKERFILE} ${CONTEXT_DIR}