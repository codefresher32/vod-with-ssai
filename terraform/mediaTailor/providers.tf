terraform {
  required_providers {
    awsmt = {
      version = "~> 2.2.0"
      source  = "spring-media/awsmt"
    }
  }
}
provider "awsmt" {
  region = "eu-central-1"
}