# global variable
variable "uploader_ui_port" {}
variable "mediaconvert_endpoint" {}
variable "prefix" {
  default = "simple-elemental"
}
variable "sourceUploadFolder" {
  default = "input-source"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
      configuration_aliases = [
        aws.iam, aws.cloudfront, aws.mediatailor
      ]
    }
  }
  backend "s3" {
    bucket = "eu-north-1-dev-video-test"
    key    = "junayed/terraform/states/simpleElemental"
    region = "eu-north-1"
  }
}

provider "aws" {
  region = "eu-north-1"
}
provider "aws" {
  region = "eu-north-1"
  alias  = "iam"
}
provider "aws" {
  region = "us-east-1"
  alias  = "cloudfront"
}
provider "aws" {
  region = "eu-central-1"
  alias  = "mediatailor"
}

module "aws_elemental_video_pipeline" {
  source                = "./terraform"
  uploader_ui_port      = var.uploader_ui_port
  mediaconvert_endpoint = var.mediaconvert_endpoint
  prefix                = var.prefix
  sourceUploadFolder    = var.sourceUploadFolder

  providers = {
    aws             = aws
    aws.iam         = aws.iam,
    aws.cloudfront  = aws.cloudfront
    aws.mediatailor = aws.mediatailor
  }
}
