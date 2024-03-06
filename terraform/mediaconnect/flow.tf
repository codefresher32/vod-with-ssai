# locals {
#   cloudformation_resources = {
#     Mediaconnect = {
#       Type = "AWS::MediaConnect::Flow"
#       Properties = {
#         Name = "${var.prefix}-flow"
#         Source = {
#           IngestPort    = var.ingest_port
#           Name          = "${var.prefix}-${var.mediaconnect_protocol}-${var.ingest_port}",
#           Protocol      = var.mediaconnect_protocol,
#           WhitelistCidr = var.whitelist_cidr_address
#         }
#       }
#     }
#   }

#   cloudformation_outputs = {
#     IngressIp = {
#       Value = { "Fn::GetAtt" = ["Mediaconnect", "Source.IngestIp"] }
#     }
#     IngressArn = {
#       Value = { "Fn::GetAtt" = ["Mediaconnect", "FlowArn"] }
#     }
#   }

#   cloudformation_body = {
#     AWSTemplateFormatVersion = "2010-09-09"
#     Resources                = local.cloudformation_resources
#     Outputs                  = local.cloudformation_outputs
#   }
# }

# resource "aws_cloudformation_stack" "mediaconnect" {
#   name          = "${var.prefix}-mediaconnect-flow"
#   template_body = jsonencode(local.cloudformation_body)
# }
