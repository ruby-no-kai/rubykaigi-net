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

    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/rk22" = "shared"
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

    "kubernetes.io/role/elb"     = "1"
    "kubernetes.io/cluster/rk22" = "shared"
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
    "kubernetes.io/cluster/rk22"      = "shared"
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
    "kubernetes.io/cluster/rk22"      = "shared"
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
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "rk-public"
    Tier = "public"
  }
}
resource "aws_route" "public_v4_default" {
  route_table_id         = aws_route_table.public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
resource "aws_route" "public_v6_default" {
  route_table_id              = aws_route_table.public_rtb.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.igw.id
}


resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "rk-private"
    Tier = "private"
  }
}
resource "aws_route" "private_v6_default" {
  route_table_id              = aws_route_table.private_rtb.id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.eigw.id
}

resource "aws_route_table" "onpremises_rtb" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "rk-onpremises"
    Tier = "onpremises"
  }
}
resource "aws_route_table" "onpremises-c_rtb" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "rk-onpremises-c"
    Tier = "onpremises"
  }
}
resource "aws_route_table" "onpremises-d_rtb" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "rk-onpremises-d"
    Tier = "onpremises"
  }
}

resource "aws_route_table" "onpremises-link_rtb" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "rk-onpremises-link"
    Tier = "onpremises-link"
  }
}

resource "aws_route_table_association" "public" {
  for_each       = local.public_subnet_ids
  subnet_id      = each.value
  route_table_id = aws_route_table.public_rtb.id
}
resource "aws_route_table_association" "private" {
  for_each       = local.private_subnet_ids
  subnet_id      = each.value
  route_table_id = aws_route_table.private_rtb.id
}
resource "aws_route_table_association" "onpremises-c" {
  subnet_id      = aws_subnet.c_onpremises.id
  route_table_id = aws_route_table.onpremises-c_rtb.id
}
resource "aws_route_table_association" "onpremises-d" {
  subnet_id      = aws_subnet.d_onpremises.id
  route_table_id = aws_route_table.onpremises-d_rtb.id
}
resource "aws_route_table_association" "onpremises-link" {
  for_each       = local.onpremises_link_subnet_ids
  subnet_id      = each.value
  route_table_id = aws_route_table.onpremises-link_rtb.id
}

resource "aws_vpn_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main"
  }
}

resource "aws_vpn_gateway_route_propagation" "main-public" {
  vpn_gateway_id = aws_vpn_gateway.main.id
  route_table_id = aws_route_table.public_rtb.id
}
resource "aws_vpn_gateway_route_propagation" "main-private" {
  vpn_gateway_id = aws_vpn_gateway.main.id
  route_table_id = aws_route_table.private_rtb.id
}
resource "aws_vpn_gateway_route_propagation" "main-onpremises-link" {
  vpn_gateway_id = aws_vpn_gateway.main.id
  route_table_id = aws_route_table.onpremises-link_rtb.id
}

resource "aws_eip" "nat" {
  vpc = true
  tags = {
    Name = "nat"
  }
}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.c_public.id
}
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_nat_gateway" "onpremises-c" {
  subnet_id         = aws_subnet.c_onpremises_link.id
  connectivity_type = "private"
}
resource "aws_nat_gateway" "onpremises-d" {
  subnet_id         = aws_subnet.d_onpremises_link.id
  connectivity_type = "private"
}
resource "aws_route" "onpremises_c_nat" {
  route_table_id         = aws_route_table.onpremises-c_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.onpremises-c.id
}
resource "aws_route" "onpremises_d_nat" {
  route_table_id         = aws_route_table.onpremises-d_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.onpremises-d.id
}
