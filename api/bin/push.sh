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

ECR=$(aws ecr describe-repositories --repository-names $REPO --region ${AWS_REGION} | jq -r ".repositories[0].repositoryUri")
echo $ECR
aws ecr get-login-password  --region ${AWS_REGION}  | docker login --username AWS --password-stdin ${ECR}
docker tag ${REPO}:${TAG} ${ECR}:${TAG}
docker push ${ECR}:${TAG}