resource "aws_kms_key" "nextcloud_s3_key" {
  description         = "This key is used to encrypt Nextcloud S3 bucket objects"
  enable_key_rotation = true
}

# Create an S3 bucket for Nextcloud data
resource "aws_s3_bucket" "nextcloud_s3_bucket" {
  bucket = var.nextcloud_s3_bucket_name

  tags = {
    Name = "Nextcloud-S3-Storage"
  }
}

resource "aws_s3_bucket_versioning" "nextcloud_s3_versioning" {
  bucket = aws_s3_bucket.nextcloud_s3_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "nextcloud_s3_bucket" {
  bucket = aws_s3_bucket.nextcloud_s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.nextcloud_s3_key.arn
    }
  }

}

resource "aws_s3_bucket_public_access_block" "nextcloud_s3_bucket" {
  bucket = aws_s3_bucket.nextcloud_s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "nextcloud_s3_bucket" {
  bucket = aws_s3_bucket.nextcloud_s3_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred" # Allows using ACLs
  }
}

resource "aws_s3_bucket_acl" "nextcloud_s3_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.nextcloud_s3_bucket,
    aws_s3_bucket_public_access_block.nextcloud_s3_bucket,
  ]

  bucket = aws_s3_bucket.nextcloud_s3_bucket.id
  acl    = "private"
}
