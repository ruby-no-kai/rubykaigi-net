# to share nlb with dhcp and tftp
# some pxe clients can expect dhcp-server-id to be a tftp server
locals {
  nlb_addresses = {
    for k, v in tomap(local.nlb_subnets) :
    k => { subnet = v, address = cidrhost(v.cidr_block, 67) }
  }
}
resource "aws_lb" "nlb" {
  name               = "dhcp-${substr(uuid(), 0, 10)}"
  internal           = true
  load_balancer_type = "network"

  dynamic "subnet_mapping" {
    for_each = tomap(local.nlb_addresses)
    content {
      subnet_id            = subnet_mapping.value.subnet.id
      private_ipv4_address = subnet_mapping.value.address
    }
  }

  lifecycle {
    ignore_changes = [name]
  }
}
output "nlb_arn" {
  value = aws_lb.nlb.arn
}

resource "aws_lb_listener" "dhcp" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = "67"
  protocol          = "UDP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dhcp.arn
  }
}

resource "aws_lb_target_group" "dhcp" {
  name        = "dhcp-kea4-${substr(uuid(), 0, 10)}"
  target_type = "ip"
  port        = 67
  protocol    = "UDP"
  vpc_id      = data.aws_vpc.main.id

  connection_termination = true
  deregistration_delay   = 10

  load_balancing_cross_zone_enabled = false # because server_id is set to NLB address in the same subnet (choose_dhcp_server_id.rb)

  health_check {
    protocol = "HTTP"
    port     = 10067
    path     = "/healthz"
    interval = 10
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "kubernetes_manifest" "targetgroupbinding-dhcp-kea4" {
  manifest = {
    "apiVersion" = "elbv2.k8s.aws/v1beta1"
    "kind"       = "TargetGroupBinding"
    "metadata" = {
      "name"      = "dhcp-kea4"
      "namespace" = "default"
    }

    "spec" = {
      "serviceRef" = {
        "name" = "kea4"
        "port" = "dhcp"
      },
      "targetGroupARN" = aws_lb_target_group.dhcp.arn
    }
  }
}

# For choose_dhcp_server_id.rb
resource "kubernetes_config_map" "server-ids" {
  metadata {
    name      = "kea-server-ids"
    namespace = "default"
  }

  data = {
    "server-ids.json" = jsonencode({
      server_ids = [
        for addr in values(local.nlb_addresses) : "${addr.address}/${replace(addr.subnet.cidr_block, "/^[^\\/]+\\//", "")}"
      ]
    })
  }
}
