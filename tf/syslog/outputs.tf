output "nlb_arn" {
  value = aws_lb.nlb.arn
}

output "nlb_security_group" {
  value = aws_security_group.nlb.id
}

output "nlb_ips" {
  value = local.nlb_ips
}
