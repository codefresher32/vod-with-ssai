# locals {
#   destination_name             = "${var.prefix}-mediapackage"
#   audio_description_name       = "${var.prefix}-1"
#   video_description_name_1080p = "${var.prefix}-1080p"
#   video_description_name_720p  = "${var.prefix}-720p"
#   video_description_name_480p  = "${var.prefix}-480p"
# }

# resource "aws_medialive_channel" "channel" {
#   name          = "${var.prefix}-channel"
#   channel_class = "SINGLE_PIPELINE"
#   role_arn      = aws_iam_role.medialive_iam_role.arn

#   input_specification {
#     codec            = "MPEG2"
#     input_resolution = "HD"
#     maximum_bitrate  = "MAX_20_MBPS"
#   }

#   input_attachments {
#     input_attachment_name = "${var.prefix}-mediaconnect-input"
#     input_id              = aws_medialive_input.input.id
#     input_settings {
#       source_end_behavior = "CONTINUE"
#     }
#   }

#   destinations {
#     id = local.destination_name
#     media_package_settings {
#       channel_id = var.mediapackage_channel_id
#     }
#   }

#   encoder_settings {
#     timecode_config {
#       source = "EMBEDDED"
#     }

#     audio_descriptions {
#       audio_selector_name   = local.audio_description_name
#       name                  = local.audio_description_name
#       audio_type_control    = "FOLLOW_INPUT"
#       language_code_control = "FOLLOW_INPUT"
#     }

#     video_descriptions {
#       name = local.video_description_name_1080p
#       codec_settings {
#         h264_settings {
#           framerate_numerator   = 25
#           framerate_denominator = 1
#           framerate_control     = "SPECIFIED"
#           par_control           = "SPECIFIED"
#           timecode_insertion    = "DISABLED"
#         }
#       }
#       height = 1080
#       width  = 1920
#     }

#     video_descriptions {
#       name = local.video_description_name_720p
#       codec_settings {
#         h264_settings {
#           framerate_numerator   = 25
#           framerate_denominator = 1
#           framerate_control     = "SPECIFIED"
#           par_control           = "SPECIFIED"
#           timecode_insertion    = "DISABLED"
#         }
#       }
#       height = 720
#       width  = 1280
#     }

#     video_descriptions {
#       name = local.video_description_name_480p
#       codec_settings {
#         h264_settings {
#           framerate_numerator   = 25
#           framerate_denominator = 1
#           framerate_control     = "SPECIFIED"
#           par_control           = "SPECIFIED"
#           timecode_insertion    = "DISABLED"
#         }
#       }
#       height = 480
#       width  = 720
#     }

#     output_groups {
#       name = "${var.prefix}-mediapackage"
#       outputs {
#         output_name             = "${var.prefix}-1080p"
#         video_description_name  = local.video_description_name_1080p
#         audio_description_names = [local.audio_description_name]
#         output_settings {
#           media_package_output_settings {}
#         }
#       }

#       outputs {
#         output_name             = "${var.prefix}-720p"
#         video_description_name  = local.video_description_name_720p
#         audio_description_names = [local.audio_description_name]
#         output_settings {
#           media_package_output_settings {}
#         }
#       }

#       outputs {
#         output_name             = "${var.prefix}-480p"
#         video_description_name  = local.video_description_name_480p
#         audio_description_names = [local.audio_description_name]
#         output_settings {
#           media_package_output_settings {}
#         }
#       }

#       output_group_settings {
#         media_package_group_settings {
#           destination {
#             destination_ref_id = local.destination_name
#           }
#         }
#       }

#     }
#   }
# }
