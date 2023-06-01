resource "aws_rds_cluster" "kea" {
  cluster_identifier = "kea1"
  engine             = "aurora-mysql"
  engine_version     = "8.0.mysql_aurora.3.02.2"

  database_name = "kea"

  master_username = "rk"
  master_password = "himitsudayo"

  db_subnet_group_name = "rk-private"

  vpc_security_group_ids = [aws_security_group.kea-db.id]

  backup_retention_period = 2
  preferred_backup_window = "12:00-14:00"

  final_snapshot_identifier = "kea-rk23-final"

  apply_immediately = true
}


resource "aws_rds_cluster_instance" "kea-001" {
  identifier         = "kea-001"
  cluster_identifier = aws_rds_cluster.kea.id
  instance_class     = "db.t4g.medium"
  engine             = aws_rds_cluster.kea.engine
  engine_version     = aws_rds_cluster.kea.engine_version
}

resource "aws_security_group" "kea-db" {
  name        = "kea-db"
  description = "rubykaigi-nw tf/kea"
  vpc_id      = data.aws_vpc.main.id
}

resource "aws_security_group_rule" "kea-db_k8s-node" {
  security_group_id        = aws_security_group.kea-db.id
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.k8s.outputs.node_security_group
}

resource "aws_security_group_rule" "kea-db_icmp" {
  security_group_id = aws_security_group.kea-db.id
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

data "aws_security_group" "bastion" {
  vpc_id = data.aws_vpc.main.id
  name   = "bastion"
}
resource "aws_security_group_rule" "kea-db_bastion" {
  security_group_id        = aws_security_group.kea-db.id
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = data.aws_security_group.bastion.id
}

resource "aws_route53_record" "kea1-db-apne1-rubykaigi-net" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.id
  name    = "kea1.db.apne1.rubykaigi.net."
  type    = "CNAME"
  ttl     = 5
  records = [
    "${aws_rds_cluster.kea.endpoint}.",
  ]
}
