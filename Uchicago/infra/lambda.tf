
resource "aws_s3_bucket" "uchicago_lambda_bucket" {
  bucket = var.lambda_code_bucket
  tags = {
      Name        = "${var.clientName}-${var.product}-${var.environment}"
      ClientName  = var.clientName
      Environment = var.environment
      Owner       = var.owner
      Project     = var.product
      createdBy   = var.createdBy
    }
}


resource "aws_s3_object" "uchicago_lambda_zip" {
  bucket = aws_s3_bucket.uchicago_lambda_bucket.bucket
  key    = "lambda_function.zip"
  source = "infra/lambda_function.zip"
}

resource "aws_dynamodb_table" "uchicago_lambda_trigger_data" {
  name         = "LambdaTriggerData"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ID"

  attribute {
    name = "ID"
    type = "S"
  }
  tags = {
      Name        = "${var.clientName}-${var.product}-${var.environment}"
      ClientName  = var.clientName
      Environment = var.environment
      Owner       = var.owner
      Project     = var.product
      createdBy   = var.createdBy
    }
}

resource "aws_iam_role" "uchicago_lambda_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "uchicago_lambda_policy" {
  name = "lambda_exec_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "uchicago_lambda_policy_attachment" {
  role       = aws_iam_role.uchicago_lambda_role.name
  policy_arn = aws_iam_policy.uchicago_lambda_policy.arn
}


resource "aws_lambda_function" "uchicago_lambda" {
  filename         = "${path.module}/lambda_function.zip"
  function_name    = "uchicago_lambda"
  role             = aws_iam_role.uchicago_lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")
  runtime          = "python3.8"
  timeout          = 10

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.uchicago_lambda_trigger_data.name
    }
    tags = {
        Name        = "${var.clientName}-${var.product}-${var.environment}"
        ClientName  = var.clientName
        Environment = var.environment
        Owner       = var.owner
        Project     = var.product
        createdBy   = var.createdBy
      }
  }
}


resource "aws_cloudwatch_event_rule" "every_five_minutes" {
  name                = "every_five_minutes"
  schedule_expression = "cron(0/5 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "uchicago_lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_five_minutes.name
  target_id = "uchicago_lambda"
  arn       = aws_lambda_function.uchicago_lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.uchicago_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_five_minutes.arn
}
