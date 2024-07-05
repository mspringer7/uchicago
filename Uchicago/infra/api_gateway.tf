resource "aws_api_gateway_rest_api" "uchicago_api" {
  name        = "lambda_api"
  description = "API Gateway for Lambda Function"
  tags = {
      Name        = "${var.clientName}-${var.product}-${var.environment}"
      ClientName  = var.clientName
      Environment = var.environment
      Owner       = var.owner
      Project     = var.product
      createdBy   = var.createdBy
    }
}

resource "aws_api_gateway_resource" "uchicago_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.uchicago_api.id
  parent_id   = aws_api_gateway_rest_api.uchicago_api.root_resource_id
  path_part   = "lambda"
}

resource "aws_api_gateway_method" "uchicago_api_method" {
  rest_api_id   = aws_api_gateway_rest_api.uchicago_api.id
  resource_id   = aws_api_gateway_resource.uchicago_api_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "uchicago_api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.uchicago_api.id
  resource_id             = aws_api_gateway_resource.uchicago_api_resource.id
  http_method             = aws_api_gateway_method.uchicago_api_method.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.uchicago_lambda.invoke_arn
}


resource "aws_lambda_permission" "uchicago_api_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.uchicago_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.uchicago_api.execution_arn}/*/*"
}


resource "aws_api_gateway_deployment" "lambda_api_deployment" {
  depends_on = [aws_api_gateway_integration.uchicago_api_integration]

  rest_api_id = aws_api_gateway_rest_api.uchicago_api.id
  stage_name  = "prod"
}

resource "aws_lambda_permission" "uchicago_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.uchicago_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.uchicago_api.execution_arn}/*/*"
  qualifier     = aws_lambda_alias.uchicago_alias.name
}

resource "aws_lambda_alias" "uchicago_alias" {
  name             = "uchicago"
  description      = "Alias for uchicago Lambda function"
  function_name    = aws_lambda_function.uchicago_lambda.function_name
  function_version = "$LATEST"
}

output "api_url" {
  value = "${aws_api_gateway_rest_api.uchicago_api.execution_arn}prod/lambda"
}


resource "aws_cloudwatch_log_group" "api_gw_logs" {
  name              = "/aws/api-gateway/lambda_api"
  retention_in_days = 7
}
