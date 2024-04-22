resource "aws_acm_certificate" "static_mediatailor_cert" {
  domain_name       = local.mediatailor_cloudfront_hostname
  validation_method = "DNS"
  provider          = aws.cloudfront

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "static_mediatailor_route53_validation_record" {
  name       = tolist(aws_acm_certificate.static_mediatailor_cert.domain_validation_options)[0].resource_record_name
  type       = tolist(aws_acm_certificate.static_mediatailor_cert.domain_validation_options)[0].resource_record_type
  zone_id    = var.hosted_zone.zone_id
  records    = [tolist(aws_acm_certificate.static_mediatailor_cert.domain_validation_options)[0].resource_record_value]
  ttl        = 60
  depends_on = [aws_acm_certificate.static_mediatailor_cert]
}

resource "aws_acm_certificate_validation" "static_mediatailor_cert_validation" {
  certificate_arn         = aws_acm_certificate.static_mediatailor_cert.arn
  validation_record_fqdns = [aws_route53_record.static_mediatailor_route53_validation_record.fqdn]
  provider                = aws.cloudfront
}

resource "aws_route53_record" "cloudfront_record_mediatailor_static" {
  depends_on = [aws_cloudfront_distribution.cf_distribution_mediatailor]
  zone_id    = var.hosted_zone.zone_id
  name       = local.mediatailor_cloudfront_hostname
  type       = "A"

  alias {
    name                   = aws_cloudfront_distribution.cf_distribution_mediatailor.domain_name
    zone_id                = aws_cloudfront_distribution.cf_distribution_mediatailor.hosted_zone_id
    evaluate_target_health = false
  }
}