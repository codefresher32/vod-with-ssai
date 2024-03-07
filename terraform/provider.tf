# provider "aws" {

#   default_tags {
#     tags = {
#       (var.billing_tag) = local.project_name
#     }
#   }
# }

provider "aws" {
  region = "eu-north-1"
}
provider "aws" {
  region = "eu-north-1"
  alias = "iam"
}