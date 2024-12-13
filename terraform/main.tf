provider "aws" {
  region = var.aws_region
}

# Lookup the Route 53 Hosted Zone
data "aws_route53_zone" "main" {
  name = var.domain_name
}

# Lookup the ACM Certificate for *.privacy.net
data "aws_acm_certificate" "wildcard_cert" {
  domain      = "*.${var.domain_name}"
  statuses    = ["ISSUED"]
  most_recent = true
}

# Render the docker-compose.yaml template
data "template_file" "docker_compose" {
  template = file("./docker-compose-template.yaml")

  vars = {
    bucket_name = var.nextcloud_s3_bucket_name
    region      = var.aws_region
  }
}


resource "aws_instance" "nextcloud" {
  ami           = "ami-09b0a86a2c84101e1" # Ubuntu 22 LTS AMI
  instance_type = "t3a.small"             # "t2.micro"

  depends_on = [
    aws_s3_bucket.nextcloud_s3_bucket,
    aws_ebs_volume.nextcloud_ebs
  ]

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  subnet_id       = aws_subnet.nextcloud_subnet_a.id
  security_groups = [aws_security_group.nextcloud_sg.id]
  key_name        = var.nextcloud_key_pair_name

  tags = {
    Name = "Nextcloud-Server"
  }

  # Attach IAM role to EC2 instance
  iam_instance_profile = aws_iam_instance_profile.nextcloud_s3_profile.name

  user_data = <<-EOF
              #!/bin/bash
              # Update and install Docker
              apt-get update -y
              apt-get install -y docker.io docker-compose
              apt-get install -y nfs-common  # Needed for mounting EBS volume

              # Start and enable Docker
              systemctl start docker
              systemctl enable docker

              # Format and mount the EBS volume
              mkfs.ext4 /dev/sdh
              mkdir -p /opt/nextcloud
              mount /dev/sdh /opt/nextcloud
              echo "/dev/sdh /opt/nextcloud ext4 defaults 0 0" >> /etc/fstab

              # Create a directory for Nextcloud
              mkdir -p /opt/nextcloud

              cat << 'COMPOSE_FILE' > /opt/nextcloud/docker-compose.yaml
              ${data.template_file.docker_compose.rendered}
              COMPOSE_FILE

              # Start Nextcloud with Docker Compose
              cd /opt/nextcloud
              docker-compose up -d
              EOF
}

# Create a Route 53 record to point to the ALB
resource "aws_route53_record" "nextcloud_dns" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${var.subdomain}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.nextcloud_alb.dns_name
    zone_id                = aws_lb.nextcloud_alb.zone_id
    evaluate_target_health = true
  }
}

output "nextcloud_url" {
  value = "https://${var.subdomain}.${var.domain_name}"
}

# Output for debugging or further use
output "docker_compose" {
  value = data.template_file.docker_compose.rendered
}
