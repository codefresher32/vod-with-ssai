resource "aws_s3_bucket" "vod_source" {
  bucket = "${var.prefix}-vod-source"
  tags = {
    Environment = "Dev"
  }
  force_destroy = true
}

resource "aws_s3_bucket_cors_configuration" "s3_playground_cors_configuration" {
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