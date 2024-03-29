
resource "aws_iam_role" "media_convert_role" {
  provider           = aws.iam
  name               = "${var.prefix}-media-convert-role"
  assume_role_policy = data.aws_iam_policy_document.mediaconvert_assume_role_policy_document.json
}

data "aws_iam_policy_document" "mediaconvert_assume_role_policy_document" {
  provider = aws.iam
  version  = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["mediaconvert.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "mediaconvert_policy_document_for_s3" {
  provider = aws.iam
  version  = "2012-10-17"

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = ["arn:aws:s3:::${var.vod_source_bucket_name}/*"]
  }
}
resource "aws_iam_policy" "mediaconvert_policy_for_s3" {
  provider = aws.iam
  name     = "${var.prefix}-media-convert-policy-for-s3"
  policy   = data.aws_iam_policy_document.mediaconvert_policy_document_for_s3.json
}
resource "aws_iam_role_policy_attachment" "vod_source_lambda_policy_attachment_cwLogs" {
  provider   = aws.iam
  role       = aws_iam_role.media_convert_role.name
  policy_arn = aws_iam_policy.mediaconvert_policy_for_s3.arn
}