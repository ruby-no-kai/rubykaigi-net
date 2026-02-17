resource "aws_rds_cluster" "grafana" {
  cluster_identifier = "grafana1"
  engine             = "aurora-mysql"
  engine_version     = "8.0.mysql_aurora.3.10.0"

  database_name = "grafana"

  master_username                     = "root"
  manage_master_user_password         = true
  iam_database_authentication_enabled = true

  db_subnet_group_name = "rk-private"

  vpc_security_group_ids = [aws_security_group.grafana-db.id]

  backup_retention_period = 2
  preferred_backup_window = "12:00-14:00"

  final_snapshot_identifier = "grafana-rk26-final"

  apply_immediately = true
}


resource "aws_rds_cluster_instance" "grafana-001" {
  identifier         = "grafana-001"
  cluster_identifier = aws_rds_cluster.grafana.id
  instance_class     = "db.t4g.medium"
  engine             = aws_rds_cluster.grafana.engine
  engine_version     = aws_rds_cluster.grafana.engine_version
  ca_cert_identifier = "rds-ca-ecc384-g1"
}

resource "aws_security_group" "grafana-db" {
  name        = "grafana-db"
  description = "rubykaigi-net//tf/grafana"
  vpc_id      = data.aws_vpc.main.id
}

resource "aws_security_group_rule" "grafana-db_k8s-node" {
  security_group_id        = aws_security_group.grafana-db.id
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = data.terraform_remote_state.k8s.outputs.node_security_group
}

resource "aws_security_group_rule" "grafana-db_icmp" {
  security_group_id = aws_security_group.grafana-db.id
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
resource "aws_security_group_rule" "grafana-db_bastion" {
  security_group_id        = aws_security_group.grafana-db.id
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = data.aws_security_group.bastion.id
}

resource "aws_route53_record" "grafana1-db-apne1-rubykaigi-net" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.id
  name    = "grafana1.db.apne1.rubykaigi.net."
  type    = "CNAME"
  ttl     = 5
  records = [
    "${aws_rds_cluster.grafana.endpoint}.",
  ]
}
