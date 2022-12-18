resource "aws_security_group" "autoscaling" {
  name        = "${local.env_code}-autoscaling"
  description = "Allows connections to web servers"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "HTTP"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.loadbalancer.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.env_code}-autoscaling"
  }
}

module "autoscaling" {
  source = "terraform-aws-modules/autoscaling/aws"

  name                      = local.env_code
  min_size                  = 3
  max_size                  = 3
  desired_capacity          = 3
  health_check_grace_period = 400
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets
  target_group_arns         = module.loadbalancer.target_group_arns
  force_delete              = true

  launch_template_name        = local.env_code
  launch_template_description = local.env_code
  update_default_version      = true
  launch_template_version     = "$Latest"

  image_id                    = "ami-0b0dcb5067f052a63"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.autoscaling.id]
  user_data                   = filebase64("user-data.sh")
  create_iam_instance_profile = false
}