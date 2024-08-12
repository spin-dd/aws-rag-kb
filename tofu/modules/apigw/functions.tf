# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
resource "aws_lambda_function" "kb" {
  description = ""
  environment {
    variables = {
      BEDROCK_KB_ID        = var.kb.id
      BEDROCK_LLM_MODEL_ID = "anthropic.claude-3-sonnet-20240229-v1:0"
      LANGCHAIN_ENDPOINT   = "https://api.smith.langchain.com"
      LANGCHAIN_TRACING_V2 = "true"
      LANGCHAIN_PROJECT    = ""
      LANGCHAIN_API_KEY    = ""
      PROMPT_SMITH_NAME    = ""
    }
  }
  function_name = "${var.symbol.prefix}-kb"
  architectures = [
    "arm64"
  ]
  package_type = "Image"
  # handler      = "handler"
  image_uri   = "${var.ecr.repository_url}:latest"
  memory_size = 128
  role        = aws_iam_role.kb_lambda.arn
  timeout     = 60
  tracing_config {
    mode = "PassThrough"
  }
  #
  lifecycle {
    ignore_changes = [
      environment,
      #environment["CONF_AWS_SECRET_ACCESS_KEY"],
    ]
  }
  logging_config {
    log_format = "Text"
    log_group  = aws_cloudwatch_log_group.kb.name
  }
}

