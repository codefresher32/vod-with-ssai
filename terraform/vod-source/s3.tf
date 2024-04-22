resource "aws_s3_bucket" "vod_source" {
  bucket = "${var.prefix}-vod-source"
  tags = {
    Environment = "Dev"
  }
  force_destroy = true
}

resource "aws_s3_bucket_cors_configuration" "vod_source_cors_configuration" {
  bucket = aws_s3_bucket.vod_source.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = [
      "http://localhost:${var.uploader_ui_port}"
    ]
    expose_headers  = ["ETag"]
    max_age_seconds = var.s3_cors_max_age_seconds
  }
  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.vod_source.bucket
  policy = data.aws_iam_policy_document.bucket_policy.json
}
data "aws_iam_policy_document" "bucket_policy" {
  provider = aws.iam
  statement {
    sid    = "allow_from_cloudfront"
    effect = "Allow"

    principals {
      identifiers = [aws_cloudfront_origin_access_identity.vod_source_origin_access_identity.iam_arn]
      type        = "AWS"
    }

    actions   = ["s3:GetObject"]
    resources = [aws_s3_bucket.vod_source.arn, "${aws_s3_bucket.vod_source.arn}/*"]
  }
}