# Create an S3 bucket for Nextcloud data
resource "aws_s3_bucket" "nextcloud_s3_bucket" {
  bucket = var.nextcloud_s3_bucket_name

  tags = {
    Name = "Nextcloud-S3-Storage"
  }
}

resource "aws_s3_bucket_ownership_controls" "nextcloud_s3_bucket_ownership_controls" {
  bucket = aws_s3_bucket.nextcloud_s3_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred" # Allows using ACLs
  }
}

resource "aws_s3_bucket_acl" "nextcloud_s3_bucket_acl" {
  bucket = aws_s3_bucket.nextcloud_s3_bucket.id
  acl    = "private"
}
