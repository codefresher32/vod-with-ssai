{
   "AWSTemplateFormatVersion":"2010-09-09",
   "Resources":{
      "PlaybackConfiguration":{
        "Type":"AWS::MediaTailor::PlaybackConfiguration",
        "Properties":{
            "AdDecisionServerUrl":"${ad_decision_server_url}",
            "AvailSuppression":{
               "Mode":"${avail_suppression_mode}"
            },
            "CdnConfiguration":{
               "AdSegmentUrlPrefix":"${ad_segment_url_prefix}",
               "ContentSegmentUrlPrefix":"${content_segment_url_prefix}"
            },
            "ManifestProcessingRules":{
               "AdMarkerPassthrough":{
                  "Enabled":"${ad_marker_passthrough_enabled}"
               }
            },
            "SlateAdUrl":"${slate_ad_url}",
            "Name":"${name}",
            "TranscodeProfileName":"${transcode_profile_name}",
            "VideoContentSourceUrl":"${video_content_source_url}",
            "Tags": ${tags}
        }
      }
   },
   "Outputs": {
    "PlaybackEndpointPrefix": {
      "Value": {
        "Fn::GetAtt": [
          "PlaybackConfiguration",
          "PlaybackEndpointPrefix"
        ]
      }
    },
    "HlsConfigurationManifestEndpointPrefix": {
      "Value": {
        "Fn::GetAtt": [
            "PlaybackConfiguration",
            "HlsConfiguration.ManifestEndpointPrefix"
         ]
      }
    }
  }
}