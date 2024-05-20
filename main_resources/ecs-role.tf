# create iam policy document which allows the ecs service to assume a role
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# create iam policy document
# adding policy statement for ecs service to get app image from ecr, create cloudwatch logs
# adding policy statement for ecs service to read files from S3 bucket named 'aevi-test-env-file-bucket'
data "aws_iam_policy_document" "ecs_task_execution_policy_document" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::aevi-test-env-file-bucket/*"
    ]
  }

  statement {
    actions    = [
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::aevi-test-env-file-bucket"
    ]
  }

  statement {
    actions    = [
      "rds:DescribeDBClusters",
      "rds:DescribeDBInstances",
      "rds:Connect"
    ]

    resources = [
      "arn:aws:rds-db:us-east-1:account_B_profile:dbuser:<db-cluster>/<db-user>"
    ]
  }
}

# create iam policy
resource "aws_iam_policy" "ecs_task_execution_policy" {
  name   = "${var.project}-${var.environment}-ecs-task-execution-role-policy"
  policy = data.aws_iam_policy_document.ecs_task_execution_policy_document.json
}

# create an iam role
resource "aws_iam_role" "ecs_task_execution_role" {
  name                = "${var.project}-${var.environment}-ecs-task-execution-role"
  assume_role_policy  = data.aws_iam_policy_document.assume_role_policy.json
}

# attach ecs task execution policy to the iam role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}