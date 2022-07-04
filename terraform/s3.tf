resource "random_string" "bucket-name" {
  length           = 16
  special          = false
}

resource "aws_s3_bucket" "pcap-bucket" {
  bucket = "${random_string.bucket-name.id}"
  acl    = "public-read"
}