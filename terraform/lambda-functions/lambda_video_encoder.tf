
locals {
  video_encoder_lambda_name = "video-encoder"
}
data "aws_iam_policy_document" "video_encoder_lambda_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "video_encoder_lambda_role" {
  provider           = aws.iam
  name               = "${var.prefix}-${local.video_encoder_lambda_name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.video_encoder_lambda_policy_document.json
}
resource "aws_iam_role_policy_attachment" "video_encoder_basicExecution_policy_attachment" {
  role       = aws_iam_role.video_encoder_lambda_role.name
  provider   = aws.iam
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_lambda_function" "video_encoder" {
  function_name    = "${var.prefix}-${local.video_encoder_lambda_name}"
  handler          = "index.handler"
  runtime          = var.lambda_runtime
  role             = aws_iam_role.video_encoder_lambda_role.arn
  source_code_hash = filebase64sha256("${path.module}/zipped-lambdas/${local.video_encoder_lambda_name}.zip")
  filename         = "${path.module}/zipped-lambdas/${local.video_encoder_lambda_name}.zip"

  environment {
    variables = {
      VOD_SOURCE_BUCKET               = var.vod_source_bucket_name
      MEDIA_CONVERT_JOB_TEMPLATE_NAME = var.mediaconvert_job_template_name
      MEDIA_CONVERT_ENDPOINT          = var.mediaconvert_endpoint
      MEDIA_CONVERT_ROLE_ARN          = var.mediaconvert_role_arn
    }
  }
}
resource "aws_cloudwatch_log_group" "video_encoder_lambda_logGroup" {
  name              = "/aws/lambda/${aws_lambda_function.video_encoder.function_name}"
  retention_in_days = 30
}
data "aws_iam_policy_document" "video_encoder_lambda_policy_document_cwLogs" {
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
resource "aws_iam_policy" "video_encoder_lambda_policy_cwLogs" {
  provider = aws.iam
  name     = "${var.prefix}-${local.video_encoder_lambda_name}-lambda-policy-cwLogs"
  policy   = data.aws_iam_policy_document.video_encoder_lambda_policy_document_cwLogs.json
}
resource "aws_iam_role_policy_attachment" "video_encoder_lambda_policy_attachment_cwLogs" {
  provider   = aws.iam
  role       = aws_iam_role.video_encoder_lambda_role.name
  policy_arn = aws_iam_policy.video_encoder_lambda_policy_cwLogs.arn
}

resource "aws_lambda_function_url" "video_encoder_lambda_functionUrl" {
  function_name      = aws_lambda_function.video_encoder.function_name
  authorization_type = "NONE"
  cors {
    allow_origins = ["*"]
    allow_methods = ["*"]
    allow_headers = ["*"]
  }
}

data "aws_iam_policy_document" "video_encoder_mediaconvert_permissions" {
  provider = aws.iam

  statement {
    actions = [
      "mediaconvert:GetJobTemplate",
      "mediaconvert:CreateJob",
      "mediaconvert:DescribeEndpoints"
    ]
    resources = [
      "arn:aws:mediaconvert:*:*:*",
    ]
  }
}
resource "aws_iam_policy" "video_encoder_mediaconvert_policy" {
  provider = aws.iam
  name     = "${var.prefix}-${local.source_uploader_lambda_name}-mediaconvert-policy"
  policy   = data.aws_iam_policy_document.video_encoder_mediaconvert_permissions.json
}

resource "aws_iam_role_policy_attachment" "video_encoder_mediaconvert_policy_attachment" {
  provider   = aws.iam
  role       = aws_iam_role.video_encoder_lambda_role.name
  policy_arn = aws_iam_policy.video_encoder_mediaconvert_policy.arn
}
data "aws_iam_policy_document" "video_encoder_iam_pass_policy_document" {
  provider = aws.iam
  statement {
    actions = [
      "iam:PassRole",
    ]
    resources = [
      var.mediaconvert_role_arn
    ]
  }
}
resource "aws_iam_policy" "video_encoder_iam_pass_policy" {
  provider = aws.iam
  name     = "${var.prefix}-${local.source_uploader_lambda_name}-mediaconvert-iam-pass-policy"
  policy   = data.aws_iam_policy_document.video_encoder_iam_pass_policy_document.json
}
resource "aws_iam_role_policy_attachment" "video_encoder_iam_pass_policy_attachment" {
  provider   = aws.iam
  role       = aws_iam_role.video_encoder_lambda_role.name
  policy_arn = aws_iam_policy.video_encoder_iam_pass_policy.arn
}