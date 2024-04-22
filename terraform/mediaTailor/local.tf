locals {
  mediatailor_cloudfront_hostname = "${var.prefix}.vod-ads.${var.hosted_zone.domain_name}"
  content_origin = {
    origin_id            = "content-origin"
    origin_domain        = var.vod_source_cloudfront_domain
    content_path_pattern = "/outputs/*/hls/*"
  }
  mediatailor_ad_segments_origin = {
    origin_id     = "mediatailor-ad-segments"
    origin_domain = "segments.mediatailor.eu-central-1.amazonaws.com"
  }
  mediatailor_playback_origin = {
    origin_id                       = "mediatailor-manifests"
    origin_domain                   = replace(awsmt_playback_configuration.playback_configuration.playback_endpoint_prefix, "https://", ""),
    menifest_root_origin_path       = "/v1"
    menifest_root_origin_id         = "mediatailor-manifests_root"
    hls_master_manifest_origin_id   = "mediatailor-manifests_hls-master"
    hls_master_manifest_origin_path = trimsuffix(replace(awsmt_playback_configuration.playback_configuration.hls_configuration_manifest_endpoint_prefix, awsmt_playback_configuration.playback_configuration.playback_endpoint_prefix, ""), "/")
  }
  mediatailor_cloudfront_origins = [
    {
      origin_id = local.content_origin.origin_id
      domain    = local.content_origin.origin_domain
      path      = ""
    },
    {
      origin_id = local.mediatailor_ad_segments_origin.origin_id
      domain    = local.mediatailor_ad_segments_origin.origin_domain
      path      = ""
    },
    {
      origin_id = local.mediatailor_playback_origin.origin_id
      domain    = local.mediatailor_playback_origin.origin_domain
      path      = ""
    },
    {
      origin_id = local.mediatailor_playback_origin.menifest_root_origin_id
      domain    = local.mediatailor_playback_origin.origin_domain
      path      = local.mediatailor_playback_origin.menifest_root_origin_path
    },
    {
      origin_id = local.mediatailor_playback_origin.hls_master_manifest_origin_id
      domain    = local.mediatailor_playback_origin.origin_domain
      path      = local.mediatailor_playback_origin.hls_master_manifest_origin_path
    }
  ]
  mediatailor_cloudfront_cache_behaviors = [
    {
      origin_id    = local.mediatailor_playback_origin.hls_master_manifest_origin_id
      path_pattern = "${local.content_origin.content_path_pattern}.m3u8"
      cache_enable = false
    },
    {
      origin_id    = local.mediatailor_playback_origin.menifest_root_origin_id
      path_pattern = "/manifest/*"
      cache_enable = false
    },
    {
      origin_id    = local.mediatailor_playback_origin.menifest_root_origin_id
      path_pattern = "/segment/*"
      cache_enable = true
    },
    {
      origin_id    = local.content_origin.origin_id
      path_pattern = local.content_origin.content_path_pattern
      cache_enable = true
    },
    {
      origin_id    = local.mediatailor_playback_origin.origin_id
      path_pattern = "${local.mediatailor_playback_origin.menifest_root_origin_path}/*"
      cache_enable = false
    }
  ]
}