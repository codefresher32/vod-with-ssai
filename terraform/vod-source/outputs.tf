output "vod_source_bucket_name" {
  value = aws_s3_bucket.vod_source.bucket
}
output "vod_source_cloudfront_domain" {
  value = aws_cloudfront_distribution.vod_source_cf_distribution.domain_name
}
output "vod_source_bucket_arn" {
  value = aws_s3_bucket.vod_source.arn
}