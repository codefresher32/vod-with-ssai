variable "prefix" {
  type        = string
  description = "AWS Resources name prefix"
}
variable "mpd_location" {
  type    = string
  default = "DISABLED"
}
variable "origin_manifest_type" {
  type    = string
  default = "MULTI_PERIOD"
}
variable "ad_marker_passthrough_enabled" {
  type    = bool
  default = true
}
variable "slate_ad_url" {
  type    = string
  default = ""
}
variable "transcode_profile_name" {
  type    = string
  default = ""
}
variable "avail_suppression_mode" {
  type    = string
  default = "OFF"
}



variable "web_acl_id" { default = "" }

variable "trusted_signers" {
  type    = list(string)
  default = []
}

variable "ipv6_enabled" {
  type    = bool
  default = false
}

variable "mediatailor_region" {
  type    = string
  default = "eu-central-1"
}
variable "viewer_protocol_policy" {
  type    = string
  default = "https-only"

}

variable "origin_protocol_policy" {
  type    = string
  default = "https-only"
}


variable "origin_ssl_protocols" {
  type    = list(string)
  default = ["TLSv1.2"]
}

variable "cache_behavior_allowed_methods" {
  type    = list(string)
  default = ["HEAD", "GET", "OPTIONS"]
}

variable "cache_behavior_cached_methods" {
  type    = list(string)
  default = ["GET", "HEAD"]
}

variable "error_caching_min_ttl" {
  type    = number
  default = 0
}

variable "restriction_type" {
  type    = string
  default = "none"
}
variable "ssl_support_method" {
  type    = string
  default = "sni-only"
}
variable "minimum_protocol_version" {
  type    = string
  default = "TLSv1.2_2019"
}

variable "http_port" {
  type    = number
  default = 80
}

variable "https_port" {
  type    = number
  default = 443
}
variable "error_responses" {
  type = list(object({
    error_caching_min_ttl = number
    error_code            = number
  }))
  default = [
    {
      error_caching_min_ttl = 0
      error_code            = 400
    },
    {
      error_caching_min_ttl = 0
      error_code            = 403
    },
    {
      error_caching_min_ttl = 0
      error_code            = 404
    },
    {
      error_caching_min_ttl = 0
      error_code            = 405
    },
    {
      error_caching_min_ttl = 0
      error_code            = 414
    },
    {
      error_caching_min_ttl = 0
      error_code            = 416
    },
    {
      error_caching_min_ttl = 0
      error_code            = 500
    },
    {
      error_caching_min_ttl = 0
      error_code            = 501
    },
    {
      error_caching_min_ttl = 0
      error_code            = 502
    },
    {
      error_caching_min_ttl = 0
      error_code            = 503
    },
    {
      error_caching_min_ttl = 0
      error_code            = 504
    }
  ]
}
variable "default_origin_request_policy_id" {
  type    = string
  default = "none"
}
variable "managed_caching_optimized_cache_policy_id" {
  type    = string
  default = ""
}
variable "managed_caching_disabled_cache_policy_id" {
  type    = string
  default = ""
}
variable "cors_with_preflight_response_header_policy_id" {
  type    = string
  default = ""
}
variable "hosted_zone" {
  type = object({
    zone_id     = string
    domain_name = string
  })
}
variable "vod_source_cloudfront_domain" {
  type = string
}
variable "ad_decision_server_url" {
  type = string
}