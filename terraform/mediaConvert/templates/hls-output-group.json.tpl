{
  "Name": "Apple HLS",
  "Outputs": ${outputs},
  "OutputGroupSettings": {
    "Type": "HLS_GROUP_SETTINGS",
    "HlsGroupSettings": {
      "ManifestDurationFormat": "INTEGER",
      "SegmentLength": 10,
      "TimedMetadataId3Period": 10,
      "CaptionLanguageSetting": "OMIT",
      "TimedMetadataId3Frame": "PRIV",
      "CodecSpecification": "RFC_4281",
      "OutputSelection": "MANIFESTS_AND_SEGMENTS",
      "ProgramDateTimePeriod": 600,
      "MinSegmentLength": 0,
      "MinFinalSegmentLength": 0,
      "DirectoryStructure": "SINGLE_DIRECTORY",
      "ProgramDateTime": "EXCLUDE",
      "SegmentControl": "SEGMENTED_FILES",
      "ManifestCompression": "NONE",
      "ClientCache": "ENABLED",
      "StreamInfResolution": "INCLUDE",
      "AdMarkers": ["ELEMENTAL_SCTE35"]
    }
  }
}