resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        Effect = "Allow",
        Resource = "arn:aws:ssm:*:*:parameter/*"
      },
      {
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Effect = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "rds:DescribeDBInstances",
          "rds:Connect"
        ],
        Effect = "Allow",
        Resource = "*"
      },
      {
        Action = [
          "elasticache:DescribeCacheClusters",
          "elasticache:Connect"
        ],
        Effect = "Allow",
        Resource = "*"
      }
    ],
  })
}

resource "aws_iam_role_policy_attachment" "attach_lambda_policy" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_exec_role.name
}

data "archive_file" "lambda_deployment_package" {
  type        = "zip"
  output_path = "final.zip"
  source_dir  = "src"
}

resource "aws_lambda_function" "hot_trend_function" {
  function_name = "HotTrendFunction"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "app.lambda_handler"
  runtime       = "python3.9"
  filename      = data.archive_file.lambda_deployment_package.output_path
  memory_size   = 128
  timeout       = 30
  architectures = ["arm64"]

  vpc_config {
    subnet_ids         = [aws_subnet.singsong_public_subnet1.id]
    security_group_ids = [aws_security_group.singsong_security_group.id]
  }

  environment {
    variables = {
      RDSEndpoint          = aws_ssm_parameter.db_endpoint.value
      RDSUsername          = aws_ssm_parameter.db_username.value
      RDSPassword          = aws_ssm_parameter.db_password.value
      RDSName              = aws_ssm_parameter.db_name.value
      RDSPort              = aws_ssm_parameter.db_port.value
      ElastiCacheEndpoint  = aws_ssm_parameter.redis_endpoint.value
    }
  }
}

resource "aws_cloudwatch_event_rule" "schedule_rule" {
  name        = "HourlyTriggerForVpcLambda"
  description = "Trigger Lambda every fifty-five minutes of the hour."
  schedule_expression = "cron(55 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.schedule_rule.name
  target_id = "HotTrendFunction"
  arn       = aws_lambda_function.hot_trend_function.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hot_trend_function.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule_rule.arn
}