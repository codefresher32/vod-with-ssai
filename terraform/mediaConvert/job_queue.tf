resource "aws_media_convert_queue" "job_queue" {
  name         = "${var.prefix}-media-convert-job-queue"
  pricing_plan = "ON_DEMAND"

  tags = {
    Environment = "Dev"
  }
}