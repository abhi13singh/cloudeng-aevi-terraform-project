# create cloudWatch log groups
resource "aws_cloudwatch_log_group" "info_log_group" {
  name              = "/ecs/${var.project}-${var.environment}-info-logs"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "debug_log_group" {
  name              = "/ecs/${var.project}-${var.environment}-debug-logs"
  retention_in_days = 30
}

# create cloudWatch log metrics filters
resource "aws_cloudwatch_log_metric_filter" "info_filter" {
  name           = "InfoMessages"
  log_group_name = aws_cloudwatch_log_group.log_group.name
  pattern        = "{ $.level = \"INFO\" }"

  metric_transformation {
    name      = "InfoMessagesCount"
    namespace = "ECSLogs"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "debug_filter" {
  name           = "DebugMessages"
  log_group_name = aws_cloudwatch_log_group.log_group.name
  pattern        = "{ $.level = \"DEBUG\" }"

  metric_transformation {
    name      = "DebugMessagesCount"
    namespace = "ECSLogs"
    value     = "1"
  }
}

# Create cloudwatch log subscriptions filters to route logs to the appropriate Lambda functions
resource "aws_cloudwatch_log_subscription_filter" "info_subscription" {
  name            = "InfoSubscription"
  log_group_name  = aws_cloudwatch_log_group.info_log_group.name
  filter_pattern  = "{ $.level = \"INFO\" }"
  destination_arn = aws_lambda_function.info_processor.arn
}

resource "aws_cloudwatch_log_subscription_filter" "debug_subscription" {
  name            = "DebugSubscription"
  log_group_name  = aws_cloudwatch_log_group.debug_log_group.name
  filter_pattern  = "{ $.level = \"DEBUG\" }"
  destination_arn = aws_lambda_function.debug_processor.arn
}

