# Create an IAM role for EC2 with S3 access
resource "aws_iam_role" "nextcloud_s3_role" {
  name = "nextcloud_s3_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# Attach the S3 policy to the IAM role
resource "aws_iam_policy" "nextcloud_s3_policy" {
  name        = "nextcloud_s3_policy"
  description = "Policy to allow EC2 instance to access Nextcloud S3 bucket"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "s3:*"
        Resource = "arn:aws:s3:::${aws_s3_bucket.nextcloud_s3_bucket.bucket}/*"
      },
      {
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = "arn:aws:s3:::${aws_s3_bucket.nextcloud_s3_bucket.bucket}"
      }
    ]
  })
}

# Attach the policy to the IAM role
resource "aws_iam_role_policy_attachment" "nextcloud_s3_role_attachment" {
  policy_arn = aws_iam_policy.nextcloud_s3_policy.arn
  role       = aws_iam_role.nextcloud_s3_role.name
}

# Create the instance profile for the EC2 instance
resource "aws_iam_instance_profile" "nextcloud_s3_profile" {
  name = "nextcloud-s3-profile"
  role = aws_iam_role.nextcloud_s3_role.name
}
