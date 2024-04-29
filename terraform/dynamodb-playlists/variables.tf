variable "prefix" {
  type        = string
  description = "AWS Resources name prefix"
}

variable "playlists_table_billing_mode" {
  default = "PROVISIONED"
}

variable "playlists_table_read_capacity" {
  default = 5
}

variable "playlists_table_write_capacity" {
  default = 5
}
