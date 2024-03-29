variable "prefix" {
  type        = string
  description = "AWS Resources name prefix"
}
variable "lambda_runtime" {
  type    = string
  default = "nodejs20.x"
}
variable "vod_source_bucket_name" {
  type = string
}
variable "mediaconvert_job_template_name" {
  type = string
}
variable "mediaconvert_endpoint" {
  type = string
}
variable "mediaconvert_role_arn" {
  type = string
}