resource "awsmt_playback_configuration" "playback_configuration" {
  ad_decision_server_url = "${var.ad_decision_server_url}?adPreferences=[player_params.adPreferences]&durationsInSeconds=[player_params.durationsInSeconds]"
  avail_supression = {
    mode = var.avail_suppression_mode
  }
  bumper = {}
  cdn_configuration = {
    ad_segment_url_prefix      = "https://${local.mediatailor_cloudfront_hostname}/"
    content_segment_url_prefix = "https://${local.mediatailor_cloudfront_hostname}/"
  }
  dash_configuration = {
    mpd_location         = var.mpd_location
    origin_manifest_type = var.origin_manifest_type
  }
  name = "${var.prefix}-vod-ads"
  manifest_processing_rules = {
    ad_marker_passthrough = {
      enabled = var.ad_marker_passthrough_enabled
    }
  }
  slate_ad_url             = var.slate_ad_url
  transcode_profile_name   = var.transcode_profile_name
  video_content_source_url = "https://${var.vod_source_cloudfront_domain}"

  tags = {
    config = var.prefix
  }
}