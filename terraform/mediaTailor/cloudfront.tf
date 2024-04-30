locals {
  header_behavior       = "whitelist"
  cookie_behavior       = "none"
  headers               = ["Origin", "Access-Control-Request-Method", "Access-Control-Request-Headers", "User-Agent", "Host", "x-forwarded-for"]
  query_string_behavior = "all"
}

data "aws_cloudfront_cache_policy" "managed_caching_disabled_cache_policy" {
  name = "Managed-CachingDisabled"
}
data "aws_cloudfront_cache_policy" "managed_caching_optimized_cache_policy" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_origin_request_policy" "mediatailor_ssai_personalized-manifests-with-host-header" {
  name    = "${var.prefix}-mediatailor-personalized-manifests-with-host-header"
  comment = "Needed for baseUrl replacement with ad segment prefix with DASH manifests"

  cookies_config {
    cookie_behavior = local.cookie_behavior
  }
  headers_config {
    header_behavior = local.header_behavior
    headers {
      items = local.headers
    }
  }
  query_strings_config {
    query_string_behavior = local.query_string_behavior
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "${var.prefix}-origin-access-identity "
}

resource "aws_cloudfront_distribution" "cf_distribution_mediatailor" {
  comment    = "${var.prefix}-mediatailor"
  web_acl_id = var.web_acl_id

  dynamic "origin" {
    for_each = local.mediatailor_cloudfront_origins
    content {
      domain_name = origin.value.domain
      origin_path = origin.value.path
      custom_origin_config {
        http_port              = var.http_port
        https_port             = var.https_port
        origin_protocol_policy = var.origin_protocol_policy
        origin_ssl_protocols   = var.origin_ssl_protocols
      }

      origin_id = origin.value.origin_id
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    allowed_methods            = var.cache_behavior_allowed_methods
    cached_methods             = var.cache_behavior_cached_methods
    target_origin_id           = local.mediatailor_ad_segments_origin.origin_id
    cache_policy_id            = data.aws_cloudfront_cache_policy.managed_caching_optimized_cache_policy.id
    compress                   = true
    viewer_protocol_policy     = var.viewer_protocol_policy
    trusted_signers            = var.trusted_signers
    response_headers_policy_id = var.cors_with_preflight_response_header_policy_id
  }

  dynamic "ordered_cache_behavior" {
    for_each = local.mediatailor_cloudfront_cache_behaviors
    iterator = behavior

    content {
      path_pattern               = behavior.value.path_pattern
      allowed_methods            = var.cache_behavior_allowed_methods
      cached_methods             = var.cache_behavior_cached_methods
      target_origin_id           = behavior.value.origin_id
      cache_policy_id            = behavior.value.cache_enable ? data.aws_cloudfront_cache_policy.managed_caching_optimized_cache_policy.id : data.aws_cloudfront_cache_policy.managed_caching_disabled_cache_policy.id
      compress                   = true
      viewer_protocol_policy     = var.viewer_protocol_policy
      origin_request_policy_id   = !behavior.value.cache_enable ? aws_cloudfront_origin_request_policy.mediatailor_ssai_personalized-manifests-with-host-header.id : null
      trusted_signers            = var.trusted_signers
      response_headers_policy_id = var.cors_with_preflight_response_header_policy_id
    }
  }
  dynamic "custom_error_response" {
    for_each = var.error_responses
    iterator = error_response

    content {
      error_caching_min_ttl = error_response.value.error_caching_min_ttl
      error_code            = error_response.value.error_code
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = var.restriction_type
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    service   = var.prefix
    team_name = var.team_name
  }
}
