# Specify the required provider
provider "aws" {
  region = var.aws_region
}

# S3 bucket to store Okta events
resource "aws_s3_bucket" "okta_events" {
  bucket = var.bucket_name
  tags   = var.tags
}

# Enable versioning for the bucket
resource "aws_s3_bucket_versioning" "okta_events" {
  bucket = aws_s3_bucket.okta_events.id
  versioning_configuration {
    status = var.enable_bucket_versioning ? "Enabled" : "Disabled"
  }
}

# Server-side encryption for the bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "okta_events" {
  bucket = aws_s3_bucket.okta_events.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket policy to enforce SSL
resource "aws_s3_bucket_policy" "require_ssl" {
  bucket = aws_s3_bucket.okta_events.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "RequireSSLRequests"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.okta_events.arn,
          "${aws_s3_bucket.okta_events.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

# Archive file for Lambda function
data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"
  
  source {
    content  = file("${path.module}/index.py")
    filename = "index.py"  # Update to match the Python file
  }
}

# Lambda function
resource "aws_lambda_function" "process_okta_events" {
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name    = "${var.project}-${var.environment}-process-okta-events"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.lambda_handler"  # Update handler to match Python
  runtime          = "python3.10"
  timeout          = 30
  memory_size      = 128

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.okta_events.id
      PATH_PREFIX = var.s3_path_prefix
    }
  }

  tags = var.tags
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.process_okta_events.function_name}"
  retention_in_days = 14
  tags              = var.tags
}

# Lambda IAM role
resource "aws_iam_role" "lambda_role" {
  name = "${var.project}-${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Lambda IAM policy
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project}-${var.environment}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.okta_events.arn,
          "${aws_s3_bucket.okta_events.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "${aws_cloudwatch_log_group.lambda_logs.arn}:*"
        ]
      }
    ]
  })
}

# EventBridge rule
resource "aws_cloudwatch_event_rule" "okta_events" {
  name        = var.event_rule_name
  description = var.event_rule_description

  event_pattern = jsonencode({
    source      = ["foo.aws.partner/okta.com"]  # Correct this to match your actual events
    detail-type = ["Okta Event"]
  })

  tags = var.tags
}

# EventBridge target
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.okta_events.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.process_okta_events.arn
}

# Lambda permission for EventBridge
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_okta_events.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.okta_events.arn
}

# S3 Block Public Access
resource "aws_s3_bucket_public_access_block" "okta_events" {
  bucket = aws_s3_bucket.okta_events.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
