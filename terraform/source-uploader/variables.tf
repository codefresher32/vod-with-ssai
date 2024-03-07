variable "prefix" {
  type        = string
  description = "AWS Resources name prefix"
}
variable "s3_cors_max_age_seconds" {
  type    = number
  default = 3600
}
variable "uploader_ui_port" {
  type = number
}
variable "lambda_runtime" {
  type    = string
  default = "nodejs20.x"
}