
resource "aws_iam_role" "vod_source_uploader_lambda_role" {
  provider = aws.iam
  name     = "${var.prefix}-vod-source-uploader-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "vod_source_uploader_basicExecution_policy_attachment" {
  role       = aws_iam_role.vod_source_uploader_lambda_role.name
  provider   = aws.iam
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_lambda_function" "vod_source_uploader" {
  function_name    = "${var.prefix}-vod-source-uploader"
  handler          = "index.handler"
  runtime          = var.lambda_runtime
  role             = aws_iam_role.vod_source_uploader_lambda_role.arn
  source_code_hash = filebase64sha256("${path.module}/function/source-uploader.zip")
  filename         = "${path.module}/function/source-uploader.zip"
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
  name     = "vod-source-lambda_policy_cwLogs"
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