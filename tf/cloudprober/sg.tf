resource "aws_security_group" "cloudprober" {
  vpc_id      = data.aws_vpc.main.id
  name        = "cloudprober"
  description = "cloudprober"

  ingress {
    description = "cloudprober"
    protocol    = "tcp"
    from_port   = local.cloudprober_port
    to_port     = local.cloudprober_port

    security_groups = [
      data.terraform_remote_state.k8s.outputs.node_security_group,
      data.aws_security_group.bastion.id,
    ]
  }
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.main.id
  name   = "default"
}

data "aws_security_group" "bastion" {
  vpc_id = data.aws_vpc.main.id
  name   = "bastion"
}
