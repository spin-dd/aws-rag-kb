
# 実行スケジュール
resource "aws_scheduler_schedule" "lambda" {
  for_each = local.events
  #
  name       = "${var.symbol.prefix}-saving-lambda-${each.key}"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = each.value.cron_expr
  schedule_expression_timezone = "Asia/Tokyo"

  target {
    arn      = var.awstools.arn
    role_arn = var.awstools.role
    input    = jsonencode(each.value.params)
  }
}

