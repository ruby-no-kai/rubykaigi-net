resource "aws_security_group_rule" "k8s-node_trapbridge-snmptrap" {
  security_group_id        = data.terraform_remote_state.k8s.outputs.node_security_group
  description              = "trapbridge-snmptrap"
  type                     = "ingress"
  from_port                = local.trapbridge_snmptrap_target_port
  to_port                  = local.trapbridge_snmptrap_target_port
  protocol                 = "udp"
  source_security_group_id = data.terraform_remote_state.syslog.outputs.nlb_security_group
}

resource "aws_security_group_rule" "k8s-node_trapbridge-healthz" {
  security_group_id        = data.terraform_remote_state.k8s.outputs.node_security_group
  description              = "trapbridge-healthz"
  type                     = "ingress"
  from_port                = local.trapbridge_http_target_port
  to_port                  = local.trapbridge_http_target_port
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.syslog.outputs.nlb_security_group
}
