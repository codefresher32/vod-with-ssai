variable "prefix" {}
variable "uploader_ui_port" {}
variable "s3_cors_max_age_seconds" {
  type    = number
  default = 3600
}
variable "ipv6_enabled" {
  type    = bool
  default = false
}
variable "viewer_protocol_policy" {
  type    = string
  default = "https-only"

}
variable "cache_behavior_allowed_methods" {
  type    = list(string)
  default = ["HEAD", "GET", "OPTIONS"]
}

variable "cache_behavior_cached_methods" {
  type    = list(string)
  default = ["GET", "HEAD"]
}
variable "restriction_type" {
  type    = string
  default = "none"
}
variable "minimum_protocol_version" {
  type    = string
  default = "TLSv1.2_2019"
}
variable "cors_with_preflight_response_header_policy_id" {
  type = string
}
variable "smooth_streaming" {
  type = bool
  default = true
}
variable "cache_behavior_compress" {
  type = bool
  default = true
}