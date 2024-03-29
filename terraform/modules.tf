# module "mediaconnect" {
#   source = "./mediaconnect"
#   prefix                 = var.prefix
#   mediaconnect_protocol  = var.mediaconnect_settings.mediaconnect_protocol
#   whitelist_cidr_address = var.mediaconnect_settings.whitelist_cidr_address
#   ingest_port            = var.mediaconnect_settings.ingest_port
# }

# module "medialive" {
#   source                  = "./medialive"
#   prefix                  = var.prefix
#   mediaconnect_flow_arn   = module.mediaconnect.flow_arn
#   mediapackage_channel_id = module.mediapackage.channel_id
# }

# module "mediapackage" {
#   source = "./mediapackage"
#   prefix = var.prefix
# }
module "lambda-functions" {
  depends_on                     = [ module.media-convert ]
  source                         = "./lambda-functions"
  prefix                         = var.prefix
  vod_source_bucket_name         = aws_s3_bucket.vod_source.bucket
  mediaconvert_job_template_name = module.media-convert.media_convert_job_template_name
  mediaconvert_endpoint          = var.mediaconvert_endpoint
  mediaconvert_role_arn          = module.media-convert.media_convert_role_arn
  providers = {
    aws     = aws
    aws.iam = aws.iam
  }
}
module "media-convert" {
  source                 = "./mediaConvert"
  prefix                 = var.prefix
  vod_source_bucket_name = aws_s3_bucket.vod_source.bucket
  providers = {
    aws     = aws
    aws.iam = aws.iam
  }
}