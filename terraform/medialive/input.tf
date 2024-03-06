# resource "aws_medialive_input" "input" {
#   name     = "${var.prefix}-mediaconnect"
#   type     = "MEDIACONNECT"
#   role_arn = aws_iam_role.medialive_iam_role.arn

#   media_connect_flows {
#     flow_arn = var.mediaconnect_flow_arn
#   }
# }
