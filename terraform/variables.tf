variable "domain_name" {
  default = "privfacy.net"
}

variable "subdomain" {
  default = "nextcloud"
}

variable "aws_region" {
  default = "ap-south-1"
}

variable "aws_availability_zone_1" {
  default = "ap-south-1a"
}

variable "aws_availability_zone_2" {
  default = "ap-south-1b"
}

variable "nextcloud_key_pair_name" {
  default = "nextcloud-key-pair"
}

variable "nextcloud_s3_bucket_name" {
  default = "nextcloud-data-bucket-2"
}
