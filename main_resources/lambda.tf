# create iam policy document which allows the lambda function to assume a role
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# create iam policy document
data "aws_iam_policy_document" "lambda_log_policy_document" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "s3:PutObject"
    ]

    resources = ["*"]
  }
}

# create iam policy
resource "aws_iam_policy" "lambda_execution_role_policy" {
  name   = "${var.project}-${var.environment}-lambda-execution-role-policy"
  policy = data.aws_iam_policy_document.lambda_log_policy_document.json
}

# create an iam role
resource "aws_iam_role" "lambda_role" {
  name                = "${var.project}-${var.environment}-lambda-log-role"
  assume_role_policy  = data.aws_iam_policy_document.assume_role_policy.json

}

# attach lambda execution policy to the iam role
resource "aws_iam_role_policy_attachment" "lambda_execution_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_execution_role_policy.arn
}
     
# create Lambda functions for processing INFO messages
resource "aws_lambda_function" "info_processor" {
  filename         = "../../info-processor.py"
  function_name    = "InfoLogProcessor"
  role             = aws_iam_role.lambda_role.arn
  handler          = "info_processor.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("../../info-processor.py")

  environment {
    variables = {
      LOG_GROUP = "/ecs/${var.project}-${var.environment}-info-logs"
    }
  }
}

# create Lambda functions for processing DEBUG messages
resource "aws_lambda_function" "debug_processor" {
  filename         = "../../debug-processor.py"
  function_name    = "DebugLogProcessor"
  role             = aws_iam_role.lambda_role.arn
  handler          = "debug_processor.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("../../debug-processor.py")

  environment {
    variables = {
      BUCKET_NAME = "${var.project}-${var.environment}-debug-logs-bucket"
    }
  }
}

resource "aws_s3_bucket" "debug_logs" {
  bucket = "${var.project}-${var.environment}-debug-logs-bucket"
}

