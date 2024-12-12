# Create an EBS volume
resource "aws_ebs_volume" "nextcloud_ebs" {
  availability_zone = aws_subnet.nextcloud_subnet_a.availability_zone
  size              = 50 # Size in GB, adjust as needed
  tags = {
    Name = "Nextcloud-Storage"
  }
  encrypted = true
}

# Attach the EBS volume to the Nextcloud instance
resource "aws_volume_attachment" "nextcloud_ebs_attachment" {
  device_name = "/dev/sdh"
  instance_id = aws_instance.nextcloud.id
  volume_id   = aws_ebs_volume.nextcloud_ebs.id
}
