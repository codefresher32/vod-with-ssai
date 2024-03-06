# locals {
#   cloudformation_resources = {
#     Mediapackage = {
#       Type = "AWS::MediaPackage::OriginEndpoint"
#       Properties = {
#         Id        = "${var.prefix}-hls"
#         ChannelId = aws_media_package_channel.channel.id
#         HlsPackage = {
#           PlaylistType = "EVENT"
#         }
#       }
#     }
#   }

#   cloudformation_outputs = {
#     HlsEndpointUrl = {
#       Value = { "Fn::GetAtt" = ["Mediapackage", "Url"] }
#     }

#   }

#   cloudformation_body = {
#     AWSTemplateFormatVersion = "2010-09-09"
#     Resources                = local.cloudformation_resources
#     Outputs                  = local.cloudformation_outputs
#   }
# }

# resource "aws_cloudformation_stack" "origin_endpoint" {
#   name          = "${var.prefix}-endpoint"
#   template_body = jsonencode(local.cloudformation_body)
# }

# resource "aws_media_package_channel" "channel" {
#   channel_id = "${var.prefix}-channel"
# }
