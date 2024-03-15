{
  "AWSTemplateFormatVersion" : "2010-09-09",
  "Resources": {
    "JobTemplate": {
      "Type": "AWS::MediaConvert::JobTemplate",
      "Properties": {
        "Category": "${category}",
        "Description": "${description}",
        "Name": "${name}",
        "Queue": "${queue_arn}",
        "SettingsJson": ${settings_json}
      }
    }
  },
  "Outputs": {
    "JobTemplateName": {
      "Value": {
        "Fn::GetAtt": [
          "JobTemplate",
          "Name"
        ]
      }
    }
  }
}