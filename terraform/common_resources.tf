locals {
  response_header_access_control_allow_credentials = false
  response_header_access_control_allow_headers     = ["*"]
  response_header_access_control_expose_headers    = ["*"]
  response_header_access_control_allow_methods     = ["ALL"]
  response_header_access_control_allow_origins     = ["*"]
  response_header_access_control_max_age_in_second = 600
  response_header_origin_override                  = true

}
resource "aws_cloudfront_response_headers_policy" "cors_with_preflight_response_header_policy" {
  name = "${var.prefix}-cors-with-preflight-override"

  cors_config {
    access_control_allow_credentials = local.response_header_access_control_allow_credentials

    access_control_allow_headers {
      items = local.response_header_access_control_allow_headers
    }

    access_control_allow_methods {
      items = local.response_header_access_control_allow_methods
    }

    access_control_allow_origins {
      items = local.response_header_access_control_allow_origins
    }

    access_control_expose_headers {
      items = local.response_header_access_control_expose_headers
    }

    access_control_max_age_sec = local.response_header_access_control_max_age_in_second

    origin_override = local.response_header_origin_override
  }
}
