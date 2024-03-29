variable "prefix" {}
variable "uploader_ui_port" {}
variable "mediaconvert_endpoint" {}
variable "s3_cors_max_age_seconds" {
  type    = number
  default = 3600
}

# variable "billing_tag" {
#   type        = string
#   description = "AWS billing tag value"
#   default     = "billing"
# }

# variable "budget_settings" {
#   type = object({
#     set_budget = bool
#     amount     = number
#     threshold  = number
#     emails     = list(string)
#   })
#   description = "aws budget settings"
#   default = {
#     set_budget = false
#     amount     = 0
#     threshold  = 70
#     emails     = []
#   }
# }

# variable "mediaconnect_settings" {
#   type = object({
#     mediaconnect_protocol  = string
#     whitelist_cidr_address = string
#     ingest_port            = number
#   })
#   description = "AWS Elemental mediaconnect settings"
# }
