
locals {
  content_curator_lambda_name = "content-curator"
}

data "aws_iam_policy_document" "content_curator_lambda_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "content_curator_lambda_role" {
  provider           = aws.iam
  name               = "${var.prefix}-${local.content_curator_lambda_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.content_curator_lambda_policy_document.json
}

resource "aws_lambda_function" "content_curator_lambda" {
  function_name    = "${var.prefix}-${local.content_curator_lambda_name}"
  handler          = "index.handler"
  runtime          = var.lambda_runtime
  role             = aws_iam_role.content_curator_lambda_role.arn
  source_code_hash = filebase64sha256("${path.module}/zipped-lambdas/${local.content_curator_lambda_name}.zip")
  filename         = "${path.module}/zipped-lambdas/${local.content_curator_lambda_name}.zip"

  environment {
    variables = {
      VOD_SOURCE_BUCKET_CDN_DOMAIN = var.vod_source_cloudfront_domain
      VOD_SOURCE_BUCKET            = var.vod_source_bucket_name
      PLAYLISTS_DYNAMODB_TABLE     = "${var.prefix}-video-playlists"
    }
  }

  tags = {
    service   = var.prefix
    team_name = var.team_name
  }
}

resource "aws_lambda_function_url" "content_curator_lambda_functionUrl" {
  function_name      = aws_lambda_function.content_curator_lambda.function_name
  authorization_type = "NONE"
  cors {
    allow_origins = ["*"]
    allow_methods = ["*"]
    allow_headers = ["*"]
  }
}

resource "aws_cloudwatch_log_group" "content_curator_lambda_logGroup" {
  name              = "/aws/lambda/${aws_lambda_function.content_curator_lambda.function_name}"
  retention_in_days = 30
}

data "aws_iam_policy_document" "content_curator_lambda_policy_document_cwLogs" {
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

resource "aws_iam_policy" "content_curator_lambda_policy_cwLogs" {
  provider = aws.iam
  name     = "${var.prefix}-${local.content_curator_lambda_name}-lambda-policy-cwLogs"
  policy   = data.aws_iam_policy_document.content_curator_lambda_policy_document_cwLogs.json
}

resource "aws_iam_role_policy_attachment" "content_curator_lambda_policy_attachment_cwLogs" {
  provider   = aws.iam
  role       = aws_iam_role.content_curator_lambda_role.name
  policy_arn = aws_iam_policy.content_curator_lambda_policy_cwLogs.arn
}

data "aws_iam_policy_document" "dynamo_content_curator_permissions" {
  provider = aws.iam
  statement {
    effect = "Allow"

    actions = [
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "dynamo_content_curator_policy" {
  provider = aws.iam
  name     = "${var.prefix}-${local.content_curator_lambda_name}-dynamo-content-curator-policy"
  policy   = data.aws_iam_policy_document.dynamo_content_curator_permissions.json
}

resource "aws_iam_role_policy_attachment" "dynamo_content_curator_policy_attachment" {
  provider   = aws.iam
  role       = aws_iam_role.content_curator_lambda_role.name
  policy_arn = aws_iam_policy.dynamo_content_curator_policy.arn
}
