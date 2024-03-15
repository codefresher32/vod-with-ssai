{
  "ContainerSettings": {
    "Container": "M3U8",
    "M3u8Settings": {
      "Scte35Source": "PASSTHROUGH"
    }
  },
  "AudioDescriptions": [
    {
      "AudioSourceName": "${audio_selector_name}",
      "CodecSettings": {
        "Codec": "AAC",
        "AacSettings": {
          "Bitrate": ${bitrate},
          "CodingMode": "CODING_MODE_2_0",
          "SampleRate": ${sample_rate}
        }
      }
    }
  ],
  "OutputSettings": {
    "HlsSettings": {
      "AudioTrackType": "${audio_track_type}"
    }
  },
  "NameModifier": "${name_modifier}"
}