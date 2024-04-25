locals {
  mediatailor_cloudfront_hostname = "change-me-later.com"
}
resource "aws_cloudformation_stack" "mediatailor" {
  name     = "${var.prefix}-meidatailor-vod-ads"
  provider = aws.mediatailor
  tags = {
    team_name = "simple_elemental"
  }
  template_body = templatefile("${path.module}/templates/mediatailor_cloudformation.json.tpl",
    {
      name                          = "${var.prefix}-vod-ads"
      ad_decision_server_url        = "${var.ad_decision_server_url}?availIndex=[avail.index]&adPreferences=[player_params.adPreferences]&durationsInSeconds=[player_params.durationsInSeconds]"
      avail_suppression_mode        = var.avail_suppression_mode
      ad_segment_url_prefix         = "https://${local.mediatailor_cloudfront_hostname}/"
      content_segment_url_prefix    = "https://${local.mediatailor_cloudfront_hostname}/"
      ad_marker_passthrough_enabled = var.ad_marker_passthrough_enabled
      slate_ad_url                  = var.slate_ad_url
      transcode_profile_name        = var.transcode_profile_name
      video_content_source_url      = "https://${var.vod_source_cloudfront_domain}"
      tags                          = jsonencode([{ Key = "team_name", Value = "simple_elemental" }, { Key = "environment", Value = "production" }])
    }
  )
}