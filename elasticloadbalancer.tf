# Target Group
resource "aws_lb_target_group" "elizabethfolzgroup-tg" {
  name     = "elizabethfolzgroup-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ElizabethFolzGroup_VPC.id
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    interval            = 90
    timeout             = 60
    path                = "/indextest.html"
  }
}

# Target Group Attachment
resource "aws_lb_target_group_attachment" "elizabethfolzgroup-tg-att" {
  target_group_arn = aws_lb_target_group.elizabethfolzgroup-tg.arn
  target_id        = aws_instance.ElizabethFolzGroup_WebApp.id
  port             = 80
}

# Elastic Load Balancer
resource "aws_lb" "elizabethfolzgroup-elb" {
  name                       = "elizabethfolzgroup-elb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.ElizabethFolzGroup_Frontend_SG.id]
  subnets                    = [aws_subnet.ElizabethFolzGroup_Public_SN1.id, aws_subnet.ElizabethFolzGroup_Public_SN2.id]
  enable_deletion_protection = false
  access_logs {
    bucket = "aws_s3_bucket.elizabethfolzgroup-elblogs"
    prefix = "elizabethfolzgroup"
  }
}

# Load Balancer Listerner
resource "aws_lb_listener" "elizabethfolzgroup-elb-listener" {
  load_balancer_arn = aws_lb.elizabethfolzgroup-elb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elizabethfolzgroup-tg.arn
  }
}