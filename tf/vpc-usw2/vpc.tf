resource "aws_vpc" "main" {
  cidr_block                       = "10.34.128.0/18"
  assign_generated_ipv6_cidr_block = true
  enable_dns_support               = true
  enable_dns_hostnames             = true

  tags = {
    Name = "rubykaigi-usw2"
  }
}

resource "aws_vpc_dhcp_options" "main" {
  domain_name         = "usw2.rubykaigi.net"
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
  availability_zone               = "us-west-2c"
  vpc_id                          = aws_vpc.main.id
  cidr_block                      = "10.34.128.0/21"
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 192) #c0
  assign_ipv6_address_on_creation = true
  map_public_ip_on_launch         = true

  tags = {
    Name = "rk-c-public"
    Tier = "public"
  }
}
resource "aws_subnet" "d_public" {
  availability_zone               = "us-west-2d"
  vpc_id                          = aws_vpc.main.id
  cidr_block                      = "10.34.144.0/21"
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 208) #d0
  assign_ipv6_address_on_creation = true
  map_public_ip_on_launch         = true

  tags = {
    Name = "rk-d-public"
    Tier = "public"
  }
}

resource "aws_subnet" "c_private" {
  availability_zone               = "us-west-2c"
  vpc_id                          = aws_vpc.main.id
  cidr_block                      = "10.34.136.0/21"
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 193) #c1
  assign_ipv6_address_on_creation = true
  map_public_ip_on_launch         = false

  tags = {
    Name = "rk-c-private"
    Tier = "private"
  }
}
resource "aws_subnet" "d_private" {
  availability_zone               = "us-west-2d"
  vpc_id                          = aws_vpc.main.id
  cidr_block                      = "10.34.152.0/21"
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.main.ipv6_cidr_block, 8, 209) #d1
  assign_ipv6_address_on_creation = true
  map_public_ip_on_launch         = false

  tags = {
    Name = "rk-d-private"
    Tier = "private"
  }
}

locals {
  public_subnet_ids = {
    c = aws_subnet.c_public.id,
    d = aws_subnet.d_public.id,
  }
  private_subnet_ids = {
    c = aws_subnet.c_private.id,
    d = aws_subnet.d_private.id,
  }
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

