output "ad_decision_server_url" {
  value = module.lambda-functions.ad_decision_server_url
}
output "content_curator_lambda_url" {
  value = module.lambda-functions.content_curator_lambda_url
}
output "media_convert_queue_arn" {
  value = module.media-convert.media_convert_queue_arn
}
output "media_convert_role_arn" {
  value = module.media-convert.media_convert_role_arn
}
output "media_convert_job_template_name" {
  value = module.media-convert.media_convert_job_template_name
}
output "mediatailor_cloudfront_domain" {
  value = module.media-Tailor.mediatailor_cloudfront_domain
}
output "vod_source_bucket_name" {
  value = module.vod_source.vod_source_bucket_name
}
output "vod_source_cloudfront_domain" {
  value = module.vod_source.vod_source_cloudfront_domain
}
output "vod_source_bucket_arn" {
  value = module.vod_source.vod_source_bucket_arn
}

