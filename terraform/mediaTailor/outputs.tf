output "mediatailor_cloudfront_domain" {
  value = aws_cloudfront_distribution.cf_distribution_mediatailor.domain_name
}
