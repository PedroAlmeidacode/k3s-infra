output "lb_target_group_arn" {
  value = aws_lb_target_group.pa_tg.arn
}


output "lb_endpoint" {
  value = aws_lb.pa_lb.dns_name
}