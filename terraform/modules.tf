module "lambda-functions" {
  depends_on                     = [module.media-convert]
  source                         = "./lambda-functions"
  prefix                         = var.prefix
  team_name                      = var.team_name
  vod_source_bucket_name         = module.vod_source.vod_source_bucket_name
  mediaconvert_job_template_name = module.media-convert.media_convert_job_template_name
  mediaconvert_endpoint          = var.mediaconvert_endpoint
  mediaconvert_role_arn          = module.media-convert.media_convert_role_arn
  sourceUploadFolder             = var.sourceUploadFolder
  vod_source_cloudfront_domain   = module.vod_source.vod_source_cloudfront_domain
  vod_source_bucket_arn          = module.vod_source.vod_source_bucket_arn

  providers = {
    aws     = aws
    aws.iam = aws.iam
  }
}
module "media-convert" {
  source                 = "./mediaConvert"
  prefix                 = var.prefix
  team_name              = var.team_name
  vod_source_bucket_name = module.vod_source.vod_source_bucket_name
  providers = {
    aws     = aws
    aws.iam = aws.iam
  }
}
module "media-Tailor" {
  source                                        = "./mediaTailor"
  prefix                                        = var.prefix
  team_name                                     = var.team_name
  cors_with_preflight_response_header_policy_id = aws_cloudfront_response_headers_policy.cors_with_preflight_response_header_policy.id
  vod_source_cloudfront_domain                  = module.vod_source.vod_source_cloudfront_domain
  ad_decision_server_url                        = module.lambda-functions.ad_decision_server_url
  providers = {
    aws             = aws
    aws.iam         = aws.iam
    aws.cloudfront  = aws.cloudfront
    aws.mediatailor = aws.mediatailor
  }
}

module "vod_source" {
  source                                        = "./vod-source"
  prefix                                        = var.prefix
  uploader_ui_port                              = var.uploader_ui_port
  team_name                                     = var.team_name
  cors_with_preflight_response_header_policy_id = aws_cloudfront_response_headers_policy.cors_with_preflight_response_header_policy.id
  providers = {
    aws            = aws
    aws.iam        = aws.iam
    aws.cloudfront = aws.cloudfront
  }
}

module "dynamodb_playlists" {
  source    = "./dynamodb-playlists"
  prefix    = var.prefix
  team_name = var.team_name
  providers = {
    aws     = aws
    aws.iam = aws.iam
  }
}
