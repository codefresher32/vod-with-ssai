resource "aws_dynamodb_table" "video_playlists_dynamodb_table" {
  name           = "${var.prefix}-video-playlists"
  billing_mode   = var.playlists_table_billing_mode
  read_capacity  = var.playlists_table_read_capacity
  write_capacity = var.playlists_table_write_capacity
  hash_key       = "contentType"
  range_key      = "contentId"

  attribute {
    name = "contentType"
    type = "S"
  }

  attribute {
    name = "contentId"
    type = "S"
  }

  tags = {
    service   = var.prefix
    team_name = var.team_name
  }
}