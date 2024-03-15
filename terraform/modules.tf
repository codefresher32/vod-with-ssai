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
module "source-uploader" {
  source           = "./source-uploader"
  prefix           = var.prefix
  uploader_ui_port = var.uploader_ui_port
  providers = {
    aws     = aws
    aws.iam = aws.iam
  }
}
module "media-convert" {
  source        = "./mediaConvert"
  prefix        = var.prefix
  providers = {
    aws     = aws
    aws.iam = aws.iam
  }
}