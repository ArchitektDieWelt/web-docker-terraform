resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-role-${var.name}"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow"
      }
    ]
  }
  EOF
}

# setup permission to read the zip from the lambda bucket
# see https://aws.amazon.com/blogs/security/how-to-restrict-amazon-s3-bucket-access-to-a-specific-iam-role/
resource "aws_iam_role_policy" "read_from_root_s3" {
  name = "iam_policy-${var.name}-read-root-s3"
  role = aws_iam_role.lambda_exec_role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject"
        ],
        "Resource": "arn:aws:s3:::${var.bucket}/${var.name}/*"
      }
    ]
  }
  EOF
}

resource "aws_lambda_permission" "lambda_invocation_permission" {
  count          = var.source_principal != "" ? 1 : 0
  statement_id   = "${var.name}-permission-${count.index}"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.lambda_function.function_name
  principal      = var.source_principal
  source_arn     = var.source_arn
  source_account = var.source_account
}

// attach a policy from a policy file (if one has been passed)
resource "aws_iam_role_policy" "lambda_exec_policy" {
  count = var.policy_file != "" ? 1 : 0

  name   = "iam_policy-${var.name}"
  role   = aws_iam_role.lambda_exec_role.id
  policy = var.policy_file != "" ? templatefile(format("${path.module}/../../iam/%s.json", var.policy_file), {}) : ""
}

// attach a policy directly passed to the module if any
resource "aws_iam_role_policy" "lambda_exec_passed_policy" {
  count = var.policy_file != "" ? 0 : 1

  name = "iam_policy-${var.name}"
  role = aws_iam_role.lambda_exec_role.id

  policy = var.policy
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.name}"
  retention_in_days = 14
}

resource "aws_lambda_function" "lambda_function" {
  function_name = var.name
  handler       = var.handler
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = var.runtime

  s3_bucket = var.bucket
  s3_key    = "${var.gitName == "" ? var.name : var.gitName}/${var.ref}.zip"

  reserved_concurrent_executions = var.concurrent_executions

  memory_size = var.memory_size
  layers      = var.layers

  environment {
    variables = var.environmentVariables
  }

  timeout = var.timeout

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  tags = {
    Name        = "lambda-${var.name}"
    Type        = var.name
    Project     = var.project
    Environment = var.environment
    Note        = var.description
  }
}

resource "aws_cloudwatch_metric_alarm" "error_alarm" {
  count                     = length(var.sns_error_notification_topics) > 0 ? 1 : 0
  alarm_name                = "lambda-error-alarm-${var.name}"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "Errors"
  namespace                 = "AWS/Lambda"
  period                    = "120"
  statistic                 = "Sum"
  threshold                 = "0"
  alarm_description         = "Error reported in the Lambda: ${var.name}"
  alarm_actions             = var.sns_error_notification_topics
  insufficient_data_actions = []
  dimensions = {
    FunctionName = var.name
  }
}
