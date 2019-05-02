resource "aws_security_group" "default" {
  vpc_id = "${aws_vpc.main.id}"
  name = "default"
  description = "default VPC security group"

  ingress {
    protocol = "icmp"
    from_port = -1
    to_port = -1
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    security_groups = ["${aws_security_group.bastion.id}"]
  }

  ingress {
    description = "prometheus-exporter-proxy"
    protocol = "tcp"
    from_port = 9099
    to_port = 9100
    security_groups = ["${aws_security_group.prometheus.id}"]
  }


  egress {
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "bastion" {
  vpc_id = "${aws_vpc.main.id}"
  name = "bastion"
  description = "bastion"

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "dns_cache" {
  vpc_id = "${aws_vpc.main.id}"
  name = "dns-cache"
  description = "dns-cache"

  ingress {
    protocol = "tcp"
    from_port = 53
    to_port = 53
    cidr_blocks = ["10.33.0.0/16"]
    security_groups = ["${aws_security_group.default.id}"]
  }
  ingress {
    protocol = "udp"
    from_port = 53
    to_port = 53
    cidr_blocks = ["10.33.0.0/16"]
    security_groups = ["${aws_security_group.default.id}"]
  }
}

resource "aws_security_group" "dhcp" {
  vpc_id = "${aws_vpc.main.id}"
  name = "dhcp"
  description = "dhcp"

  ingress {
    protocol = "udp"
    from_port = 67
    to_port = 68
    cidr_blocks = [
      "10.33.1.1/32",
      "10.33.2.1/32",
      "10.33.64.1/32",
      "10.33.1.2/32",
      "10.33.2.2/32",
      "10.33.64.2/32",
      "10.33.100.10/32",
    ]
  }
}

resource "aws_security_group" "vpn_router" {
  vpc_id = "${aws_vpc.main.id}"
  name = "vpn-router"
  description = "vpn-router"

  ingress {
    protocol = -1
    from_port = 0
    to_port = 0
    security_groups = ["${aws_security_group.default.id}"]
  }
  ingress {
    protocol = "udp"
    from_port = 500
    to_port = 500
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    protocol = "tcp"
    from_port = 500
    to_port = 500
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    protocol = "udp"
    from_port = 4500
    to_port = 4500
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    protocol = 50
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "syslog" {
  vpc_id = "${aws_vpc.main.id}"
  name = "syslog"
  description = "syslog"

  ingress {
    protocol = "udp"
    from_port = 514
    to_port = 514
    cidr_blocks = [
      "10.33.0.0/16",
    ]
  }

  ingress {
    protocol = "tcp"
    from_port = 514
    to_port = 514
    cidr_blocks = [
      "10.33.0.0/16",
    ]
  }
}


resource "aws_security_group" "elb_http" {
  vpc_id = "${aws_vpc.main.id}"
  name = "elb-http"
  description = "elb-http"

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "front_http" {
  vpc_id = "${aws_vpc.main.id}"
  name = "front-http"
  description = "front-http"

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
    security_groups = ["${aws_security_group.elb_http.id}"]
  }

  ingress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    security_groups = ["${aws_security_group.elb_http.id}"]
  }
}

resource "aws_security_group" "prometheus" {
  vpc_id = "${aws_vpc.main.id}"
  name = "prometheus"
  description = "prometheus"

  ingress {
    description = "prometheus"
    protocol = "tcp"
    from_port = 9090
    to_port = 9090
    security_groups = ["${aws_security_group.front_http.id}"]
  }

  ingress {
    description = "alertmanager"
    protocol = "tcp"
    from_port = 9093
    to_port = 9093
    security_groups = ["${aws_security_group.front_http.id}"]
  }

  ingress {
    description = "grafana"
    protocol = "tcp"
    from_port = 5446
    to_port = 5446
    security_groups = ["${aws_security_group.front_http.id}"]
  }
}
