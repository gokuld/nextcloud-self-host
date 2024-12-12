# Create the ALB
#trivy:ignore:AVD-AWS-0053 # expose ALB publicly, that's fine.
resource "aws_lb" "nextcloud_alb" {
  name               = "nextcloud-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.nextcloud_subnet_a.id, aws_subnet.nextcloud_subnet_b.id] # Provide the subnet IDs where the ALB will be deployed

  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
  drop_invalid_header_fields       = true
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.nextcloud_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      status_code = "HTTP_301" # Permanent redirect
      protocol    = "HTTPS"
      port        = "443"
      host        = "#{host}"
      path        = "/#{path}"
      query       = "#{query}"
    }
  }
}

# Create an ALB listener for HTTPS (with the ACM certificate)
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.nextcloud_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.wildcard_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nextcloud_target_group.arn
  }
}

# Define the target group for the EC2 instance (Nextcloud)
resource "aws_lb_target_group" "nextcloud_target_group" {
  name     = "nextcloud-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.nextcloud_vpc.id

  health_check {
    path                = "/index.php"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}
