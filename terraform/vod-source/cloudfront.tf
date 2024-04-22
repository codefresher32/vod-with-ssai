resource "aws_cloudfront_origin_access_identity" "vod_source_origin_access_identity" {
  comment = "${var.prefix}-origin-access-identity "
}
resource "aws_cloudfront_distribution" "vod_source_cf_distribution" {
  comment    = "${var.prefix}-vod-source"

  origin {
    domain_name = aws_s3_bucket.vod_source.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.vod_source.bucket_regional_domain_name
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.vod_source_origin_access_identity.cloudfront_access_identity_path
    }
  }
  enabled         = true
  is_ipv6_enabled = var.ipv6_enabled

  default_cache_behavior {
    allowed_methods            = var.cache_behavior_allowed_methods
    cached_methods             = var.cache_behavior_cached_methods
    target_origin_id           = aws_s3_bucket.vod_source.bucket_regional_domain_name
    cache_policy_id            = data.aws_cloudfront_cache_policy.managed_caching_disabled_cache_policy.id
    compress                   = var.cache_behavior_compress
    viewer_protocol_policy     = var.viewer_protocol_policy
    response_headers_policy_id = var.cors_with_preflight_response_header_policy_id
    smooth_streaming = var.smooth_streaming
  }
  restrictions {
    geo_restriction {
      restriction_type = var.restriction_type
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

data "aws_cloudfront_cache_policy" "managed_caching_disabled_cache_policy" {
  name = "Managed-CachingDisabled"
}