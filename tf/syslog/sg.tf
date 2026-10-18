resource "aws_security_group" "nlb" {
  name        = "syslog-nlb"
  description = "syslog NLB"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description = "syslog"
    from_port   = 514
    to_port     = 514
    protocol    = "udp"
    cidr_blocks = ["10.33.0.0/16"]
  }

  ingress {
    description = "snmptrap"
    from_port   = 162
    to_port     = 162
    protocol    = "udp"
    cidr_blocks = ["10.33.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }
}

resource "aws_security_group_rule" "k8s-node_syslog" {
  security_group_id        = data.terraform_remote_state.k8s.outputs.node_security_group
  description              = "syslog"
  type                     = "ingress"
  from_port                = local.syslog_target_port
  to_port                  = local.syslog_target_port
  protocol                 = "udp"
  source_security_group_id = aws_security_group.nlb.id
}

resource "aws_security_group_rule" "k8s-node_healthz" {
  security_group_id        = data.terraform_remote_state.k8s.outputs.node_security_group
  description              = "syslog-healthz"
  type                     = "ingress"
  from_port                = local.syslog_healthz_target_port
  to_port                  = local.syslog_healthz_target_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nlb.id
}
