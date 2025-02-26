locals {
  enable_nat            = false
  enable_onpremises_nat = false
}

resource "aws_vpc" "main" {
  cidr_block                       = "10.33.128.0/18"
  assign_generated_ipv6_cidr_block = true
  enable_dns_support               = true
  enable_dns_hostnames             = true

  tags = {
    Name = "rubykaigi"
  }
}

resource "aws_vpc_dhcp_options" "main" {
  domain_name         = "aws.nw.rubykaigi.org"
  domain_name_servers = ["AmazonProvidedDNS"]
  ntp_servers         = ["216.239.35.0", "216.239.35.4", "216.239.35.8", "216.239.35.12"] # time.google.com
}
resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = aws_vpc.main.id
  dhcp_options_id = aws_vpc_dhcp_options.main.id
}

resource "aws_egress_only_internet_gateway" "eigw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_network_interface" "blackhole" {
  subnet_id               = aws_subnet.d_onpremises_link.id
  private_ip_list_enabled = false
  security_groups         = [aws_security_group.default.id]
  tags = {
    Name = "blackhole"
  }
}

resource "aws_subnet" "c_public" {
  availability_zone               = "ap-northeast-1c"
  vpc_id                          = aws_vpc.main.id
  cidr_block                      = "10.33.128.0/21"
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 192) #c0
  assign_ipv6_address_on_creation = true
  map_public_ip_on_launch         = true

  tags = {
    Name = "rk-c-public"
    Tier = "public"

    "kubernetes.io/role/elb"      = "1"
    "kubernetes.io/cluster/rknet" = "shared"
  }
}
resource "aws_subnet" "d_public" {
  availability_zone               = "ap-northeast-1d"
  vpc_id                          = aws_vpc.main.id
  cidr_block                      = "10.33.144.0/21"
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 208) #d0
  assign_ipv6_address_on_creation = true
  map_public_ip_on_launch         = true

  tags = {
    Name = "rk-d-public"
    Tier = "public"

    "kubernetes.io/role/elb"      = "1"
    "kubernetes.io/cluster/rknet" = "shared"
  }
}

resource "aws_subnet" "c_private" {
  availability_zone               = "ap-northeast-1c"
  vpc_id                          = aws_vpc.main.id
  cidr_block                      = "10.33.136.0/21"
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 193) #c1
  assign_ipv6_address_on_creation = true
  map_public_ip_on_launch         = false

  tags = {
    Name = "rk-c-private"
    Tier = "private"

    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/rknet"     = "shared"
  }
}
resource "aws_subnet" "d_private" {
  availability_zone               = "ap-northeast-1d"
  vpc_id                          = aws_vpc.main.id
  cidr_block                      = "10.33.152.0/21"
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 209) #d1
  assign_ipv6_address_on_creation = true
  map_public_ip_on_launch         = false

  tags = {
    Name = "rk-d-private"
    Tier = "private"

    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/rknet"     = "shared"
  }
}

resource "aws_subnet" "c_onpremises" {
  availability_zone               = "ap-northeast-1c"
  vpc_id                          = aws_vpc.main.id
  cidr_block                      = "10.33.160.0/23"
  assign_ipv6_address_on_creation = false
  map_public_ip_on_launch         = false

  tags = {
    Name = "rk-c-onpremises"
    Tier = "onpremises"

    "kubernetes.io/cluster/rknet" = "shared"
  }
}
resource "aws_subnet" "d_onpremises" {
  availability_zone               = "ap-northeast-1d"
  vpc_id                          = aws_vpc.main.id
  cidr_block                      = "10.33.162.0/23"
  assign_ipv6_address_on_creation = false
  map_public_ip_on_launch         = false

  tags = {
    Name = "rk-d-onpremises"
    Tier = "onpremises"

    "kubernetes.io/cluster/rknet" = "shared"
  }
}
resource "aws_subnet" "c_onpremises_link" {
  availability_zone               = "ap-northeast-1c"
  vpc_id                          = aws_vpc.main.id
  cidr_block                      = "10.33.164.0/27"
  assign_ipv6_address_on_creation = false
  map_public_ip_on_launch         = false

  tags = {
    Name = "rk-c-onpremises-link"
    Tier = "onpremises-link"
  }
}
resource "aws_subnet" "d_onpremises_link" {
  availability_zone               = "ap-northeast-1d"
  vpc_id                          = aws_vpc.main.id
  cidr_block                      = "10.33.164.32/27"
  assign_ipv6_address_on_creation = false
  map_public_ip_on_launch         = false

  tags = {
    Name = "rk-d-onpremises-link"
    Tier = "onpremises-link"
  }
}

locals {
  public_subnet_ids          = toset([aws_subnet.c_public.id, aws_subnet.d_public.id])
  private_subnet_ids         = toset([aws_subnet.c_private.id, aws_subnet.d_private.id])
  onpremises_subnet_ids      = toset([aws_subnet.c_onpremises.id, aws_subnet.d_onpremises.id])
  onpremises_link_subnet_ids = toset([aws_subnet.c_onpremises_link.id, aws_subnet.d_onpremises_link.id])

  rtb_ids = {
    "public-*"     = aws_route_table.public.id
    "private-*"    = aws_route_table.private.id
    "private-c"    = aws_route_table.private-c.id
    "private-d"    = aws_route_table.private-d.id
    "onpremises-c" = aws_route_table.onpremises-c.id
    "onpremises-d" = aws_route_table.onpremises-d.id
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "rk-public"
    Tier = "public"
  }
}
resource "aws_route" "public_v4_default" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
resource "aws_route" "public_v6_default" {
  route_table_id              = aws_route_table.public.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.igw.id
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "rk-private"
    Tier = "private"
  }
}
resource "aws_route_table" "private-c" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "rk-private-c"
    Tier = "private"
  }
}
resource "aws_route_table" "private-d" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "rk-private-d"
    Tier = "private"
  }
}
resource "aws_route" "private_v6_default" {
  for_each = { for k, v in local.rtb_ids : k => v if startswith(k, "private-") }

  route_table_id              = each.value
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.eigw.id
}

resource "aws_route_table" "onpremises-c" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "rk-onpremises-c"
    Tier = "onpremises"
  }
}
resource "aws_route_table" "onpremises-d" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "rk-onpremises-d"
    Tier = "onpremises"
  }
}

resource "aws_route_table" "onpremises-link" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "rk-onpremises-link"
    Tier = "onpremises-link"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = local.public_subnet_ids
  subnet_id      = each.value
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private-c" {
  subnet_id      = aws_subnet.c_private.id
  route_table_id = aws_route_table.private-c.id
}
resource "aws_route_table_association" "private-d" {
  subnet_id      = aws_subnet.d_private.id
  route_table_id = aws_route_table.private-d.id
}
resource "aws_route_table_association" "onpremises-c" {
  subnet_id      = aws_subnet.c_onpremises.id
  route_table_id = aws_route_table.onpremises-c.id
}
resource "aws_route_table_association" "onpremises-d" {
  subnet_id      = aws_subnet.d_onpremises.id
  route_table_id = aws_route_table.onpremises-d.id
}
resource "aws_route_table_association" "onpremises-link" {
  for_each       = local.onpremises_link_subnet_ids
  subnet_id      = each.value
  route_table_id = aws_route_table.onpremises-link.id
}

resource "aws_vpn_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main"
  }
}

resource "aws_vpn_gateway_route_propagation" "main-public" {
  vpn_gateway_id = aws_vpn_gateway.main.id
  route_table_id = aws_route_table.public.id
}
resource "aws_vpn_gateway_route_propagation" "main-private" {
  vpn_gateway_id = aws_vpn_gateway.main.id
  route_table_id = aws_route_table.private.id
}
resource "aws_vpn_gateway_route_propagation" "main-private-c" {
  vpn_gateway_id = aws_vpn_gateway.main.id
  route_table_id = aws_route_table.private-c.id
}
resource "aws_vpn_gateway_route_propagation" "main-private-d" {
  vpn_gateway_id = aws_vpn_gateway.main.id
  route_table_id = aws_route_table.private-d.id
}
resource "aws_vpn_gateway_route_propagation" "main-onpremises-link" {
  vpn_gateway_id = aws_vpn_gateway.main.id
  route_table_id = aws_route_table.onpremises-link.id
}
resource "aws_vpn_gateway_route_propagation" "main-onpremises-c" {
  vpn_gateway_id = aws_vpn_gateway.main.id
  route_table_id = aws_route_table.onpremises-c.id
}
resource "aws_vpn_gateway_route_propagation" "main-onpremises-d" {
  vpn_gateway_id = aws_vpn_gateway.main.id
  route_table_id = aws_route_table.onpremises-d.id
}

resource "aws_eip" "nat-c" {
  count  = local.enable_nat ? 1 : 0
  domain = "vpc"
  tags = {
    Name    = "nat-c"
    Project = "rk25net"
  }
}
resource "aws_nat_gateway" "nat-c" {
  count         = local.enable_nat ? 1 : 0
  allocation_id = aws_eip.nat-c[0].id
  subnet_id     = aws_subnet.c_public.id
  tags = {
    Name    = "nat-c"
    Project = "rk25net"
  }
}
resource "aws_route" "private_nat" {
  count                  = local.enable_nat ? 1 : 0
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-c[0].id
}
resource "aws_route" "private_blackhole" {
  count                  = !local.enable_nat ? 1 : 0
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.blackhole.id
}
resource "aws_route" "private-c_v4_default_nat" {
  count                  = local.enable_nat ? 1 : 0
  route_table_id         = aws_route_table.private-c.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-c[0].id
}
resource "aws_route" "private-c_v4_default_blackhole" {
  count                  = !local.enable_nat ? 1 : 0
  route_table_id         = aws_route_table.private-c.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.blackhole.id
}

resource "aws_eip" "nat-d" {
  count  = local.enable_nat ? 1 : 0
  domain = "vpc"
  tags = {
    Name      = "nat-d"
    Project   = "rk25net"
    Component = "core/vpc"
  }
}
resource "aws_nat_gateway" "nat-d" {
  count         = local.enable_nat ? 1 : 0
  allocation_id = aws_eip.nat-d[0].id
  subnet_id     = aws_subnet.d_public.id
  tags = {
    Name      = "nat-d"
    Project   = "rk25net"
    Component = "core/vpc"
  }
}

resource "aws_route" "private-d_v4_default_nat" {
  count                  = local.enable_nat ? 1 : 0
  route_table_id         = aws_route_table.private-d.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat-d[0].id
}
resource "aws_route" "private-d_v4_default_blackhole" {
  count                  = !local.enable_nat ? 1 : 0
  route_table_id         = aws_route_table.private-d.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.blackhole.id
}

resource "aws_nat_gateway" "onpremises-c" {
  count             = local.enable_onpremises_nat ? 1 : 0
  subnet_id         = aws_subnet.c_onpremises_link.id
  connectivity_type = "private"
  tags = {
    Name      = "onpremises-c"
    Project   = "rk25net"
    Component = "core/vpc"
  }
}
resource "aws_nat_gateway" "onpremises-d" {
  count             = local.enable_onpremises_nat ? 1 : 0
  subnet_id         = aws_subnet.d_onpremises_link.id
  connectivity_type = "private"
  tags = {
    Name      = "onpremises-d"
    Project   = "rk25net"
    Component = "core/vpc"
  }
}
resource "aws_route" "onpremises-c_v4_default_nat" {
  count                  = local.enable_onpremises_nat ? 1 : 0
  route_table_id         = aws_route_table.onpremises-c.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.onpremises-c[0].id
  #network_interface_id = aws_network_interface.blackhole.id
}
resource "aws_route" "onpremises-d_v4_default_nat" {
  count                  = local.enable_onpremises_nat ? 1 : 0
  route_table_id         = aws_route_table.onpremises-d.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.onpremises-d[0].id
  #network_interface_id = aws_network_interface.blackhole.id
}
resource "aws_route" "onpremises-c_v4_default_blackhole" {
  count                  = !local.enable_onpremises_nat ? 1 : 0
  route_table_id         = aws_route_table.onpremises-c.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.blackhole.id
}
resource "aws_route" "onpremises-d_v4_default_blackhole" {
  count                  = !local.enable_onpremises_nat ? 1 : 0
  route_table_id         = aws_route_table.onpremises-d.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.blackhole.id
}
