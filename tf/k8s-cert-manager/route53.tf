data "aws_route53_zone" "zone" {
  for_each     = local.zones
  name         = each.key
  private_zone = false
}
