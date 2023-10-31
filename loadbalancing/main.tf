# -- loadbalancing/main.tf ---



resource "aws_lb" "pa_lb" {
  name            = "pa-loadbalancer"
  security_groups = [var.public_sg]
  subnets         = var.public_subnets
  idle_timeout    = 400

}


resource "aws_lb_target_group" "pa_tg" {
  name     = "pa-lb-tg-${substr(uuid(), 0, 3)}"
  port     = var.tg_port     # 80
  protocol = var.tg_protocol # http
  vpc_id   = var.vpc_id
  lifecycle {
    ignore_changes        = [name]
    create_before_destroy = true
  }
  health_check {
    healthy_threshold   = var.lb_healthy_threshold   # 2
    unhealthy_threshold = var.lb_unhealthy_threshold # 2
    timeout             = var.lb_timeout             # 3
    interval            = var.lb_interval            # 30
  }
}


resource "aws_lb_listener" "pa_lb_listener" {
  load_balancer_arn = aws_lb.pa_lb.arn
  port              = var.listener_port     # 80
  protocol          = var.listener_protocol # HTTP
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pa_tg.arn
  }

}