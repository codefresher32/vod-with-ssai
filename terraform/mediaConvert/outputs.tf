output "media_convert_queue_arn" {
  value = aws_media_convert_queue.job_queue.arn
}
output "media_convert_role_arn" {
  value = aws_iam_role.media_convert_role.arn
}
output "media_convert_job_template_name" {
  value = aws_cloudformation_stack.mediaconvert_job_template.outputs["JobTemplateName"]
}