
variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "lambda_code_bucket" {
  description = "S3 Bucket that contains the Lambda function"
  default = "lambda-uchicago"
}

variable "clientName" {}
variable "createdBy" {}
variable "environment" {}
variable "owner" {}
variable "product" {}
