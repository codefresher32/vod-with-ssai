
locals {
  source_uploader_lambda_name = "vod-source-uploader"
}
data "aws_iam_policy_document" "vod_source_uploader_lambda_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "vod_source_uploader_lambda_role" {
  provider           = aws.iam
  name               = "${var.prefix}-${local.source_uploader_lambda_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.vod_source_uploader_lambda_policy_document.json
}
resource "aws_iam_role_policy_attachment" "vod_source_uploader_basicExecution_policy_attachment" {
  role       = aws_iam_role.vod_source_uploader_lambda_role.name
  provider   = aws.iam
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_lambda_function" "vod_source_uploader" {
  function_name    = "${var.prefix}-${local.source_uploader_lambda_name}"
  handler          = "index.handler"
  runtime          = var.lambda_runtime
  role             = aws_iam_role.vod_source_uploader_lambda_role.arn
  source_code_hash = filebase64sha256("${path.module}/zipped-lambdas/source-uploader.zip")
  filename         = "${path.module}/zipped-lambdas/source-uploader.zip"

  environment {
    variables = {
      VOD_SOURCE_BUCKET = var.vod_source_bucket_name
    }
  }
}
resource "aws_cloudwatch_log_group" "vod_source_lambda_logGroup" {
  name              = "/aws/lambda/${aws_lambda_function.vod_source_uploader.function_name}"
  retention_in_days = 30
}
data "aws_iam_policy_document" "vod_source_lambda_policy_document_cwLogs" {
  provider = aws.iam
  version  = "2012-10-17"

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}
resource "aws_iam_policy" "vod_source_lambda_policy_cwLogs" {
  provider = aws.iam
  name     = "${var.prefix}-${local.source_uploader_lambda_name}-lambda-policy-cwLogs"
  policy   = data.aws_iam_policy_document.vod_source_lambda_policy_document_cwLogs.json
}
resource "aws_iam_role_policy_attachment" "vod_source_lambda_policy_attachment_cwLogs" {
  provider   = aws.iam
  role       = aws_iam_role.vod_source_uploader_lambda_role.name
  policy_arn = aws_iam_policy.vod_source_lambda_policy_cwLogs.arn
}

resource "aws_lambda_function_url" "vod_source_lambda_functionUrl" {
  function_name      = aws_lambda_function.vod_source_uploader.function_name
  authorization_type = "NONE"
  cors {
    allow_origins = ["*"]
    allow_methods = ["*"]
    allow_headers = ["*"]
  }
}

data "aws_iam_policy_document" "vod_source_bucket_policy_document" {
  provider = aws.iam

  statement {
    actions = [
      "s3:PutObject",
      "s3:ListBucket",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "vod_source_bucket_policy" {
  provider = aws.iam
  name     = "${var.prefix}-${local.source_uploader_lambda_name}-bucket-policy"
  policy   = data.aws_iam_policy_document.vod_source_bucket_policy_document.json
}

resource "aws_iam_role_policy_attachment" "vod_source_bucket_policy_attachment" {
  provider   = aws.iam
  role       = aws_iam_role.vod_source_uploader_lambda_role.name
  policy_arn = aws_iam_policy.vod_source_bucket_policy.arn
}