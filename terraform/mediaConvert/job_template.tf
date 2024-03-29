locals {

  hls_video_outputs_rendered = flatten([
    for s in var.video_configs : [
      jsondecode(templatefile("${path.module}/templates/hls-video-output.json.tpl", {
        height          = s.height
        width           = s.width
        bitrate         = s.bitrate
        hrd_buffer_size = s.hrd_buffer_size
        name_modifier   = s.name_modifier
      }))
    ]
  ])
  hls_audio_outputs_rendered = flatten([
    for s in var.audio_config : [
      jsondecode(templatefile("${path.module}/templates/hls-audio-output.json.tpl", {
        audio_selector_name = s.audio_selector_name
        bitrate             = s.bitrate
        sample_rate         = s.sample_rate
        audio_track_type    = s.audio_track_type
        name_modifier       = s.name_modifier
      }))
    ]
  ])
  hls_output_group_rendered = [jsondecode(templatefile("${path.module}/templates/hls-output-group.json.tpl", {
    outputs        = jsonencode(concat(local.hls_video_outputs_rendered, local.hls_audio_outputs_rendered))
    outputLocation = "s3://${var.vod_source_bucket_name}/output-video/HLS/"
  }))]
  settings_rendered = templatefile("${path.module}/templates/jobtemplate-settings.json.tpl", {
    output_groups = jsonencode(concat(local.hls_output_group_rendered))
  })
}

resource "aws_cloudformation_stack" "mediaconvert_job_template" {
  name = "${var.prefix}-${var.job_template_suffix}"
  template_body = templatefile("${path.module}/templates/cloudformation.json.tpl",
    {
      queue_arn              = aws_media_convert_queue.job_queue.arn
      name                   = "${var.prefix}-${var.job_template_suffix}"
      settings_json          = local.settings_rendered
      status_update_interval = var.status_update_interval
      category               = var.category
      description            = var.description
    }
  )
}
