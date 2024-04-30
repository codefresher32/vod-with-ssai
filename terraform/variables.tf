variable "prefix" {}
variable "team_name" {}
variable "uploader_ui_port" {}
variable "mediaconvert_endpoint" {}
variable "sourceUploadFolder" {}
variable "s3_cors_max_age_seconds" {
  type    = number
  default = 3600
}
