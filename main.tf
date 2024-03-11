terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
      configuration_aliases = [
        aws.iam,
      ]
    }
  }
  backend "s3" {
    bucket = "eu-north-1-dev-video-test"
    key    = "junayed/terraform/states/simpleElemental"
    region = "eu-north-1"
  }
}

# data "http" "current_ip" {
#   url = "https://api.ipify.org"
# }

provider "aws" {
  region = "eu-north-1"
}
provider "aws" {
  region = "eu-north-1"
  alias  = "iam"
}

variable "uploader_ui_port" {}
module "aws_elemental_video_pipeline" {
  source           = "./terraform"
  uploader_ui_port = var.uploader_ui_port
  prefix           = "simple-elemental"

  providers = {
    aws     = aws
    aws.iam = aws.iam
  }

  # mediaconnect_settings = {
  #   mediaconnect_protocol  = "srt-listener"
  #   whitelist_cidr_address = "${data.http.current_ip.response_body}/32"
  #   ingest_port            = 5000
  # }
}
