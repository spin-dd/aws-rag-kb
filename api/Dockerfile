FROM public.ecr.aws/lambda/python:3.12
# LWA(Lmabda Web Adapter)
# https://github.com/awslabs/aws-lambda-web-adapter?tab=readme-ov-file#configurations
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.8.3 /lambda-adapter /opt/extensions/lambda-adapter
ENV PORT=8000
#
COPY api/main.py ${LAMBDA_TASK_ROOT}/
COPY pyproject.toml poetry.lock ${LAMBDA_TASK_ROOT}/
COPY bedrag/ ${LAMBDA_TASK_ROOT}/bedrag/

#
RUN dnf install gcc-c++ -y

#
RUN pip install pip -U 
RUN pip install poetry
RUN poetry config virtualenvs.create false
RUN poetry install --no-root --no-dev
#
ENTRYPOINT ["uvicorn"]
CMD [ "main:app", "--host", "0.0.0.0", "--port", "8000"]