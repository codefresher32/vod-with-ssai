variable "prefix" {
  type        = string
  description = "AWS Resources name prefix"
}

variable "job_template_suffix" {
  type    = string
  default = "hls-only"
}

variable "subtitle_conversions_video_configs" {
  type = list(object({ bitrate : number, name_modifier : string }))
  default = [
    { bitrate : 64000, name_modifier : "64" }
  ]
}

variable "status_update_interval" {
  type    = string
  default = "SECONDS_60"
}

variable "category" {
  type    = string
  default = "hls-only"
}

variable "description" {
  type    = string
  default = "hls-only"
}
variable "vod_source_bucket_name" {
  type = string
}

variable "audio_config" {
  type = list(object({ bitrate : number, sample_rate : number, name_modifier : string, audio_track_type : string, audio_selector_name : string }))
  default = [
    {
      audio_selector_name : "Audio Selector 1",
      bitrate : 96000
      sample_rate : 48000,
      audio_track_type : "ALTERNATE_AUDIO_AUTO_SELECT_DEFAULT",
      name_modifier : "original"
    }
  ]
}

variable "video_configs" {
  type = list(object({ height : number, width : number, bitrate : number, hrd_buffer_size : number, name_modifier : string }))
  default = [
    { height : 360, width : 640, bitrate : 600000, hrd_buffer_size : 1200000, name_modifier : "600" },
    { height : 540, width : 960, bitrate : 1500000, hrd_buffer_size : 2400000, name_modifier : "1500" }
  ]
}
