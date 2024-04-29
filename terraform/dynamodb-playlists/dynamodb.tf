resource "aws_dynamodb_table" "portal_playlists_dynamodb_table" {
  name           = "${var.prefix}-video-portal-playlists"
  billing_mode   = var.events_table_billing_mode
  read_capacity  = var.events_table_read_capacity
  write_capacity = var.events_table_write_capacity
  hash_key       = "playlist"
  range_key      = "contentId"

  attribute {
    name = "playlist"
    type = "S"
  }

  attribute {
    name = "contentId"
    type = "S"
  }

  tags = {
    service = var.prefix
  }
}