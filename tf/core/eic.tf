resource "aws_ec2_instance_connect_endpoint" "apne1c" {
  subnet_id          = aws_subnet.c_private.id
  security_group_ids = [aws_security_group.bastion.id]
}
