resource "aws_security_group" "loadbalancer" {
  name        = "${local.env_code}-loadbalancer"
  description = "Allows connection to load balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.env_code}-loadbalancer"
  }
}

module "loadbalancer" {
  source = "terraform-aws-modules/alb/aws"

  name = local.env_code

  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  internal        = false
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.loadbalancer.id]

  target_groups = [
    {
      name_prefix          = local.env_code
      backend_protocol     = "HTTP"
      backend_port         = 80
      deregistration_delay = 10

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = "traffic-port"
        healthy_threshold   = 5
        unhealthy_threshold = 2
        timeout             = 5
        protocol            = "HTTP"
        matcher             = "200"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      action_type        = "forward"
      target_group_index = 0
    }
  ]
}
