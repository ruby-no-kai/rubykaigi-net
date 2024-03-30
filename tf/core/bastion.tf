resource "aws_iam_role" "bastion" {
  name                 = "NwBastion"
  description          = "rubykaigi-nw aws_iam_role.bastion"
  assume_role_policy   = data.aws_iam_policy_document.trust-ec2.json
  permissions_boundary = data.aws_iam_policy.NocAdminBase.arn
}

resource "aws_iam_instance_profile" "bastion" {
  name = aws_iam_role.bastion.name
  role = aws_iam_role.bastion.name
}

resource "aws_iam_role_policy_attachment" "bastion-ssm" {
  role       = aws_iam_role.bastion.name
  policy_arn = data.aws_iam_policy.ssm.arn
}

resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "bastion"
}

#resource "aws_security_group_rule" "bastion_ssh22" {
#  security_group_id = aws_security_group.bastion.id
#  type              = "ingress"
#  from_port         = 22
#  to_port           = 22
#  protocol          = "tcp"
#  cidr_blocks       = ["0.0.0.0/0"]
#  ipv6_cidr_blocks  = ["::/0"]
#}
resource "aws_security_group_rule" "bastion_ssh9922" {
  security_group_id = aws_security_group.bastion.id
  type              = "ingress"
  from_port         = 9922
  to_port           = 9922
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "bastion_iperf3" {
  security_group_id = aws_security_group.bastion.id
  type              = "ingress"
  from_port         = 5201
  to_port           = 5201
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8"]
}
