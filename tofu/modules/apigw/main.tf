# API Gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api.html
resource "aws_apigatewayv2_api" "kb" {
  name                         = "${var.symbol.prefix}-kb-api"
  api_key_selection_expression = "$request.header.x-api-key"
  route_selection_expression   = "$request.method $request.path"
  protocol_type                = "HTTP"
  #
  cors_configuration {
    allow_credentials = true
    allow_methods = [
      "*"
    ]
    allow_origins = [
      "https://*",
      "http://*"
    ]
    expose_headers = [
      "x-csrftoken, x-isauthenticated"
    ]
    max_age = 0
  }
  tags = {}
}


# デプロイメント
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_deployment
resource "aws_apigatewayv2_deployment" "kb" {
  api_id = aws_apigatewayv2_api.kb.id
  lifecycle {
    create_before_destroy = true
  }
}



# ステージ
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage
resource "aws_apigatewayv2_stage" "kb" {
  name          = "${var.symbol.prefix}-kb-stage"
  api_id        = aws_apigatewayv2_api.kb.id
  deployment_id = aws_apigatewayv2_deployment.kb.id
  default_route_settings {
    detailed_metrics_enabled = false
    throttling_burst_limit   = 10 # MUST
    throttling_rate_limit    = 10 # MUST
  }
  tags       = {}
  depends_on = [aws_cloudwatch_log_group.kb]
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.kb.arn
    format          = replace(file("${path.module}/logformat.json"), "\n", "")
  }
}


# Lambda との紐付け
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_integration
resource "aws_apigatewayv2_integration" "kb" {
  api_id                 = aws_apigatewayv2_api.kb.id
  connection_type        = "INTERNET"
  integration_method     = "POST"
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.kb.invoke_arn # Lambda
  timeout_milliseconds   = 30000
  payload_format_version = "1.0"
}


#  API ルーティング

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route
resource "aws_apigatewayv2_route" "kb" {
  for_each = toset(local.routes)
  #
  api_id             = aws_apigatewayv2_api.kb.id
  api_key_required   = false
  authorization_type = "NONE"
  route_key          = "ANY ${each.value}"
  target             = "integrations/${aws_apigatewayv2_integration.kb.id}"
}

# ドメイン名
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_domain_name
resource "aws_apigatewayv2_domain_name" "kb" {
  for_each = local.domain_names
  #
  domain_name = "${local.host}.${each.value}"
  # 
  domain_name_configuration {
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_domain_name#domain_name_configuration
    certificate_arn = aws_acm_certificate.kx.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}


# ドメイン名紐付け
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api_mapping
resource "aws_apigatewayv2_api_mapping" "kb" {
  for_each = local.domain_names
  #
  api_id      = aws_apigatewayv2_api.kb.id
  domain_name = aws_apigatewayv2_domain_name.kb[each.key].id
  stage       = aws_apigatewayv2_stage.kb.id
}


# DNS追加(CNAME)

resource "aws_route53_record" "apigw" {
  for_each = aws_apigatewayv2_domain_name.kb
  #
  name    = each.value.domain_name
  zone_id = local.zones[each.value.domain_name].zone_id
  records = [each.value.domain_name_configuration[0].target_domain_name]
  # 
  ttl             = 60
  type            = "CNAME"
  allow_overwrite = true

  depends_on = [data.aws_route53_zone.kx]
}


# Lambda の実行権限
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission
resource "aws_lambda_permission" "apigw" {
  for_each = toset(local.routes)
  #
  statement_id = replace("AllowExecutionFromAPIGateway${each.value}", "/", "_") # ユニーク
  action       = "lambda:InvokeFunction"
  principal    = "apigateway.amazonaws.com"
  #
  function_name = aws_lambda_function.kb.function_name
  source_arn    = "${aws_apigatewayv2_api.kb.execution_arn}/*/*${each.value}"
}


