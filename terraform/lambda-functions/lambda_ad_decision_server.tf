
locals {
  ad_decision_server_lambda_name = "ad-decision-server"
}
data "aws_iam_policy_document" "ad_decision_server_lambda_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "ad_decision_server_lambda_role" {
  provider           = aws.iam
  name               = "${var.prefix}-${local.ad_decision_server_lambda_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.ad_decision_server_lambda_policy_document.json
}
resource "aws_iam_role_policy_attachment" "ad_decision_server_basicExecution_policy_attachment" {
  role       = aws_iam_role.ad_decision_server_lambda_role.name
  provider   = aws.iam
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_lambda_function" "ad_decision_server" {
  function_name    = "${var.prefix}-${local.ad_decision_server_lambda_name}"
  handler          = "index.handler"
  runtime          = var.lambda_runtime
  role             = aws_iam_role.ad_decision_server_lambda_role.arn
  source_code_hash = filebase64sha256("${path.module}/zipped-lambdas/${local.ad_decision_server_lambda_name}.zip")
  filename         = "${path.module}/zipped-lambdas/${local.ad_decision_server_lambda_name}.zip"

  environment {
    variables = {
      VOD_SOURCE_BUCKET_CDN_DOMAIN = var.vod_source_cloudfront_domain
      VOD_SOURCE_BUCKET            = var.vod_source_bucket_name
    }
  }

  tags = {
    service   = var.prefix
    team_name = var.team_name
  }
}
resource "aws_cloudwatch_log_group" "ad_decision_server_lambda_logGroup" {
  name              = "/aws/lambda/${aws_lambda_function.ad_decision_server.function_name}"
  retention_in_days = 30
}
data "aws_iam_policy_document" "ad_decision_server_lambda_policy_document_cwLogs" {
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
resource "aws_iam_policy" "ad_decision_server_lambda_policy_cwLogs" {
  provider = aws.iam
  name     = "${var.prefix}-${local.ad_decision_server_lambda_name}-lambda-policy-cwLogs"
  policy   = data.aws_iam_policy_document.ad_decision_server_lambda_policy_document_cwLogs.json
}
resource "aws_iam_role_policy_attachment" "ad_decision_server_lambda_policy_attachment_cwLogs" {
  provider   = aws.iam
  role       = aws_iam_role.ad_decision_server_lambda_role.name
  policy_arn = aws_iam_policy.ad_decision_server_lambda_policy_cwLogs.arn
}

resource "aws_lambda_function_url" "ad_decision_server_lambda_functionUrl" {
  function_name      = aws_lambda_function.ad_decision_server.function_name
  authorization_type = "NONE"
  cors {
    allow_origins = ["*"]
    allow_methods = ["*"]
    allow_headers = ["*"]
  }
}

data "aws_iam_policy_document" "ad_decision_server_bucket_policy_document" {
  provider = aws.iam

  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]
    resources = ["${var.vod_source_bucket_arn}"]
  }
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]
    resources = ["${var.vod_source_bucket_arn}/*"]
  }
}

resource "aws_iam_policy" "ad_decision_server_bucket_policy" {
  provider = aws.iam
  name     = "${var.prefix}-${local.ad_decision_server_lambda_name}-bucket-policy"
  policy   = data.aws_iam_policy_document.ad_decision_server_bucket_policy_document.json
}

resource "aws_iam_role_policy_attachment" "ad_decision_server_bucket_policy_attachment" {
  provider   = aws.iam
  role       = aws_iam_role.ad_decision_server_lambda_role.name
  policy_arn = aws_iam_policy.ad_decision_server_bucket_policy.arn
}