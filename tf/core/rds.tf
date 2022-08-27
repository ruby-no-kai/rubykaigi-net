resource "aws_db_subnet_group" "rk-private" {
  name = "rk-private"
  subnet_ids = [
    aws_subnet.c_private.id,
    aws_subnet.d_private.id,
  ]
}
