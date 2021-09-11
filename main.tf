terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.48.0"
    }
  }
  required_version = "~> 1.0"
}

provider "aws" {
  region                  = var.aws_region
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "personal"
  
}

# Create a bucket for our code
# resource "aws_s3_bucket" "lambda_bucket" {
#   bucket        = "python-decrypt-zip"
#   acl           = "private"
#   force_destroy = true
# }

# Create lambda function
module "lambda" {
  source = "github.com/claranet/terraform-aws-lambda"

  function_name = "decrypt_zip"
  description   = "Decrypt a zip file"
  handler       = "handler.decrypt_zip"
  runtime       = "python3.8"
  timeout       = 300

  // Specify a file or directory for the source code.
  source_path = "${path.module}/src"

  // Add additional trusted entities for assuming roles (trust relationships).
  trusted_entities = ["events.amazonaws.com", "s3.amazonaws.com"]
}


# Create API Gateway for lambda
resource "aws_apigatewayv2_api" "lambda" {
  name          = "decrypt_zip_api_gw"
  protocol_type = "HTTP"
}


resource "aws_apigatewayv2_stage" "lambda" {
  api_id      = aws_apigatewayv2_api.lambda.id

  name        = "serverless_lambda_stage"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "decrypt_zip" {
  api_id             = aws_apigatewayv2_api.lambda.id

  integration_uri    = module.lambda.function_invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "decrypt_zip" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "POST /decrypt_zip"
  target    = "integrations/${aws_apigatewayv2_integration.decrypt_zip.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

resource "aws_cloudwatch_log_group" "decrypt_zip" {
  name = "/aws/lambda/${module.lambda.function_name}"

  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/lambda/${aws_apigatewayv2_api.lambda.name}"

  retention_in_days = 30
}