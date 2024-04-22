output "ad_decision_server_url" {
  value = aws_lambda_function_url.ad_decision_server_lambda_functionUrl.function_url
}
