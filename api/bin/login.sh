#!/bin/sh
if [ -f .env ]; then
    export $(cat .env|grep -v "^#"|xargs)
fi

export $(cat $1| jq -r 'to_entries | .[] | "\(.key)=\(.value.value)"')

#
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws