{
  "ContainerSettings": {
    "Container": "M3U8",
    "M3u8Settings": {
      "AudioFramesPerPes": 4,
      "PcrControl": "PCR_EVERY_PES_PACKET",
      "PmtPid": 480,
      "PrivateMetadataPid": 503,
      "ProgramNumber": 1,
      "PatInterval": 0,
      "PmtInterval": 0,
      "NielsenId3": "NONE",
      "TimedMetadata": "NONE",
      "VideoPid": 481,
      "Scte35Source": "PASSTHROUGH",
      "AudioPids": [
        482,
        483,
        484,
        485,
        486,
        487,
        488,
        489,
        490,
        491,
        492
      ]
    }
  },
  "VideoDescription": {
    "Width": ${width},
    "ScalingBehavior": "DEFAULT",
    "Height": ${height},
    "TimecodeInsertion": "DISABLED",
    "AntiAlias": "ENABLED",
    "Sharpness": 50,
    "CodecSettings": {
      "Codec": "H_264",
      "H264Settings": {
        "InterlaceMode": "PROGRESSIVE",
        "ParNumerator": 1,
        "NumberReferenceFrames": 3,
        "Syntax": "DEFAULT",
        "Softness": 0,
        "FramerateDenominator": 1001,
        "GopClosedCadence": 1,
        "HrdBufferInitialFillPercentage": 90,
        "GopSize": 90,
        "Slices": 1,
        "GopBReference": "ENABLED",
        "HrdBufferSize": ${hrd_buffer_size},
        "SlowPal": "DISABLED",
        "ParDenominator": 1,
        "SpatialAdaptiveQuantization": "ENABLED",
        "TemporalAdaptiveQuantization": "ENABLED",
        "FlickerAdaptiveQuantization": "ENABLED",
        "EntropyEncoding": "CABAC",
        "Bitrate": ${bitrate},
        "FramerateControl": "SPECIFIED",
        "RateControlMode": "CBR",
        "CodecProfile": "MAIN",
        "Telecine": "NONE",
        "FramerateNumerator": 30000,
        "MinIInterval": 0,
        "AdaptiveQuantization": "MEDIUM",
        "CodecLevel": "LEVEL_3_1",
        "FieldEncoding": "PAFF",
        "SceneChangeDetect": "ENABLED",
        "QualityTuningLevel": "SINGLE_PASS",
        "FramerateConversionAlgorithm": "DUPLICATE_DROP",
        "UnregisteredSeiTimecode": "DISABLED",
        "GopSizeUnits": "FRAMES",
        "ParControl": "INITIALIZE_FROM_SOURCE",
        "NumberBFramesBetweenReferenceFrames": 3,
        "RepeatPps": "DISABLED",
        "DynamicSubGop": "STATIC"
      }
    },
    "AfdSignaling": "NONE",
    "DropFrameTimecode": "ENABLED",
    "RespondToAfd": "NONE",
    "ColorMetadata": "INSERT"
  },
  "OutputSettings": {
    "HlsSettings": {
      "AudioGroupId": "program_audio",
      "AudioOnlyContainer": "AUTOMATIC",
      "IFrameOnlyManifest": "EXCLUDE"
    }
  },
  "NameModifier": "${name_modifier}"
}