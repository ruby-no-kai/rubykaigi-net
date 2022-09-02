resource "aws_route53_record" "host_1_0_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "1.0.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_br-01_hnd_dualstack_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "br-01.hnd.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.1",
  ]
}

resource "aws_route53_record" "host_br-01_hnd_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "br-01.hnd.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.1",
  ]
}

resource "aws_route53_record" "host_lo_br-01_hnd_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "lo.br-01.hnd.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.1",
  ]
}

resource "aws_route53_record" "host_gi0-2_br-01_hnd_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "gi0-2.br-01.hnd.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.1",
  ]
}

resource "aws_route53_record" "host_1_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "1.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi0-2.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gi1-2_br-01_hnd_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "gi1-2.br-01.hnd.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.5",
  ]
}

resource "aws_route53_record" "host_5_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "5.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi1-2.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun19_br-01_hnd_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun19.br-01.hnd.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.13",
  ]
}

resource "aws_route53_record" "host_13_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "13.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun19.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun8_br-01_hnd_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun8.br-01.hnd.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.17",
  ]
}

resource "aws_route53_record" "host_17_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "17.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun8.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi0_br-01_hnd_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "bvi0.br-01.hnd.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.37",
  ]
}

resource "aws_route53_record" "host_37_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "37.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi0.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi1_br-01_hnd_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "bvi1.br-01.hnd.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.41",
  ]
}

resource "aws_route53_record" "host_41_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "41.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi1.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun100_br-01_hnd_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun100.br-01.hnd.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.45",
  ]
}

resource "aws_route53_record" "host_45_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "45.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun100.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun101_br-01_hnd_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun101.br-01.hnd.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.49",
  ]
}

resource "aws_route53_record" "host_49_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "49.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun101.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi10_br-01_hnd_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "bvi10.br-01.hnd.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.69",
  ]
}

resource "aws_route53_record" "host_69_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "69.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi10.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi11_br-01_hnd_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "bvi11.br-01.hnd.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.73",
  ]
}

resource "aws_route53_record" "host_73_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "73.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi11.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun110_br-01_hnd_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun110.br-01.hnd.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.77",
  ]
}

resource "aws_route53_record" "host_77_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "77.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun110.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun111_br-01_hnd_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun111.br-01.hnd.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.81",
  ]
}

resource "aws_route53_record" "host_81_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "81.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun111.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gi3-0_br-01_hnd_rubykaigi_net_A" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "gi3-0.br-01.hnd.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "192.50.220.153",
  ]
}

resource "aws_route53_record" "host_bb_br-01_hnd_rubykaigi_net_CNAME" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bb.br-01.hnd.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "gi3-0.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_153_220_50_192_reverse_rubykaigi_net_PTR" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "153.220.50.192.reverse.rubykaigi.net"
  type = "PTR"
  ttl  = 60
  records = [
    "gi3-0.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_2_0_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "2.0.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "br-01.itm.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_br-01_itm_dualstack_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "br-01.itm.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.2",
  ]
}

resource "aws_route53_record" "host_br-01_itm_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "br-01.itm.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.2",
  ]
}

resource "aws_route53_record" "host_lo_br-01_itm_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "lo.br-01.itm.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.2",
  ]
}

resource "aws_route53_record" "host_tbd_br-01_itm_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tbd.br-01.itm.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.9",
  ]
}

resource "aws_route53_record" "host_9_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "9.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tbd.br-01.itm.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun8_br-01_itm_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun8.br-01.itm.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.18",
  ]
}

resource "aws_route53_record" "host_18_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "18.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun8.br-01.itm.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi0_br-01_itm_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "bvi0.br-01.itm.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.21",
  ]
}

resource "aws_route53_record" "host_21_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "21.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi0.br-01.itm.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi1_br-01_itm_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "bvi1.br-01.itm.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.25",
  ]
}

resource "aws_route53_record" "host_25_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "25.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi1.br-01.itm.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun100_br-01_itm_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun100.br-01.itm.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.29",
  ]
}

resource "aws_route53_record" "host_29_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "29.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun100.br-01.itm.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun101_br-01_itm_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun101.br-01.itm.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.33",
  ]
}

resource "aws_route53_record" "host_33_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "33.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun101.br-01.itm.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi10_br-01_itm_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "bvi10.br-01.itm.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.53",
  ]
}

resource "aws_route53_record" "host_53_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "53.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi10.br-01.itm.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi11_br-01_itm_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "bvi11.br-01.itm.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.57",
  ]
}

resource "aws_route53_record" "host_57_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "57.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi11.br-01.itm.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun110_br-01_itm_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun110.br-01.itm.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.61",
  ]
}

resource "aws_route53_record" "host_61_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "61.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun110.br-01.itm.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun111_br-01_itm_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun111.br-01.itm.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.65",
  ]
}

resource "aws_route53_record" "host_65_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "65.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun111.br-01.itm.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gi3-0_br-01_itm_rubykaigi_net_A" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "gi3-0.br-01.itm.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "192.50.220.155",
  ]
}

resource "aws_route53_record" "host_bb_br-01_itm_rubykaigi_net_CNAME" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bb.br-01.itm.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "gi3-0.br-01.itm.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_155_220_50_192_reverse_rubykaigi_net_PTR" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "155.220.50.192.reverse.rubykaigi.net"
  type = "PTR"
  ttl  = 60
  records = [
    "gi3-0.br-01.itm.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_11_0_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "11.0.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun-01_venue_dualstack_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun-01.venue.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.11",
  ]
}

resource "aws_route53_record" "host_tun-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.11",
  ]
}

resource "aws_route53_record" "host_lo_tun-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "lo.tun-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.11",
  ]
}

resource "aws_route53_record" "host_bvi10_tun-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "bvi10.tun-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.22",
  ]
}

resource "aws_route53_record" "host_22_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "22.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi10.tun-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi11_tun-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "bvi11.tun-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.26",
  ]
}

resource "aws_route53_record" "host_26_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "26.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi11.tun-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun110_tun-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun110.tun-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.30",
  ]
}

resource "aws_route53_record" "host_30_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "30.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun110.tun-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun111_tun-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun111.tun-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.34",
  ]
}

resource "aws_route53_record" "host_34_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "34.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun111.tun-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi0_tun-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "bvi0.tun-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.38",
  ]
}

resource "aws_route53_record" "host_38_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "38.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi0.tun-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi1_tun-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "bvi1.tun-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.42",
  ]
}

resource "aws_route53_record" "host_42_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "42.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi1.tun-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun100_tun-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun100.tun-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.46",
  ]
}

resource "aws_route53_record" "host_46_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "46.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun100.tun-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun101_tun-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun101.tun-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.50",
  ]
}

resource "aws_route53_record" "host_50_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "50.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun101.tun-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gi1-1_tun-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "gi1-1.tun-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.85",
  ]
}

resource "aws_route53_record" "host_85_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "85.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi1-1.tun-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gi1-2_tun-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "gi1-2.tun-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.101",
  ]
}

resource "aws_route53_record" "host_101_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "101.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi1-2.tun-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_12_0_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "12.0.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun-02_venue_dualstack_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun-02.venue.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.12",
  ]
}

resource "aws_route53_record" "host_tun-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.12",
  ]
}

resource "aws_route53_record" "host_lo_tun-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "lo.tun-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.12",
  ]
}

resource "aws_route53_record" "host_bvi10_tun-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "bvi10.tun-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.54",
  ]
}

resource "aws_route53_record" "host_54_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "54.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi10.tun-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi11_tun-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "bvi11.tun-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.58",
  ]
}

resource "aws_route53_record" "host_58_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "58.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi11.tun-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun110_tun-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun110.tun-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.62",
  ]
}

resource "aws_route53_record" "host_62_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "62.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun110.tun-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun111_tun-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun111.tun-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.66",
  ]
}

resource "aws_route53_record" "host_66_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "66.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun111.tun-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi0_tun-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "bvi0.tun-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.70",
  ]
}

resource "aws_route53_record" "host_70_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "70.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi0.tun-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi1_tun-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "bvi1.tun-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.74",
  ]
}

resource "aws_route53_record" "host_74_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "74.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi1.tun-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun100_tun-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun100.tun-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.78",
  ]
}

resource "aws_route53_record" "host_78_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "78.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun100.tun-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun101_tun-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun101.tun-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.82",
  ]
}

resource "aws_route53_record" "host_82_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "82.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun101.tun-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gi1-1_tun-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "gi1-1.tun-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.89",
  ]
}

resource "aws_route53_record" "host_89_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "89.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi1-1.tun-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gi1-2_tun-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "gi1-2.tun-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.105",
  ]
}

resource "aws_route53_record" "host_105_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "105.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi1-2.tun-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_21_0_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "21.0.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gw-01_venue_dualstack_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "gw-01.venue.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.21",
  ]
}

resource "aws_route53_record" "host_gw-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "gw-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.21",
  ]
}

resource "aws_route53_record" "host_lo_gw-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "lo.gw-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.21",
  ]
}

resource "aws_route53_record" "host_gi0-1_gw-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "gi0-1.gw-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.86",
  ]
}

resource "aws_route53_record" "host_86_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "86.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi0-1.gw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gi1-1-0_gw-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "gi1-1-0.gw-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.93",
  ]
}

resource "aws_route53_record" "host_93_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "93.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi1-1-0.gw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gi0-2_gw-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "gi0-2.gw-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.102",
  ]
}

resource "aws_route53_record" "host_102_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "102.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi0-2.gw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_lo1_gw-01_venue_rubykaigi_net_A" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "lo1.gw-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "192.50.220.160",
  ]
}

resource "aws_route53_record" "host_bb_gw-01_venue_rubykaigi_net_CNAME" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bb.gw-01.venue.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "lo1.gw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_160_220_50_192_reverse_rubykaigi_net_PTR" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "160.220.50.192.reverse.rubykaigi.net"
  type = "PTR"
  ttl  = 60
  records = [
    "lo1.gw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_nat_gw-01_venue_rubykaigi_net_A" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "nat.gw-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "192.50.220.161",
  ]
}

resource "aws_route53_record" "host_161_220_50_192_reverse_rubykaigi_net_PTR" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "161.220.50.192.reverse.rubykaigi.net"
  type = "PTR"
  ttl  = 60
  records = [
    "nat.gw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_22_0_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "22.0.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gw-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gw-02_venue_dualstack_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "gw-02.venue.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.22",
  ]
}

resource "aws_route53_record" "host_gw-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "gw-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.22",
  ]
}

resource "aws_route53_record" "host_lo_gw-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "lo.gw-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.22",
  ]
}

resource "aws_route53_record" "host_gi0-1_gw-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "gi0-1.gw-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.90",
  ]
}

resource "aws_route53_record" "host_90_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "90.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi0-1.gw-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gi1-1-0_gw-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "gi1-1-0.gw-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.97",
  ]
}

resource "aws_route53_record" "host_97_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "97.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi1-1-0.gw-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gi0-2_gw-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "gi0-2.gw-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.106",
  ]
}

resource "aws_route53_record" "host_106_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "106.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi0-2.gw-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_lo1_gw-02_venue_rubykaigi_net_A" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "lo1.gw-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "192.50.220.164",
  ]
}

resource "aws_route53_record" "host_bb_gw-02_venue_rubykaigi_net_CNAME" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bb.gw-02.venue.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "lo1.gw-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_164_220_50_192_reverse_rubykaigi_net_PTR" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "164.220.50.192.reverse.rubykaigi.net"
  type = "PTR"
  ttl  = 60
  records = [
    "lo1.gw-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_nat_gw-02_venue_rubykaigi_net_A" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "nat.gw-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "192.50.220.165",
  ]
}

resource "aws_route53_record" "host_165_220_50_192_reverse_rubykaigi_net_PTR" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "165.220.50.192.reverse.rubykaigi.net"
  type = "PTR"
  ttl  = 60
  records = [
    "nat.gw-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_31_0_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "31.0.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_csw-01_venue_dualstack_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "csw-01.venue.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.31",
  ]
}

resource "aws_route53_record" "host_csw-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "csw-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.31",
  ]
}

resource "aws_route53_record" "host_lo_csw-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "lo.csw-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.31",
  ]
}

resource "aws_route53_record" "host_vlan-1000_csw-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "vlan-1000.csw-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.1",
  ]
}

resource "aws_route53_record" "host_mgmt_csw-01_venue_rubykaigi_net_CNAME" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "mgmt.csw-01.venue.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "vlan-1000.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_1_100_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "1.100.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "vlan-1000.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_vlan-200_csw-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "vlan-200.csw-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.2.254",
  ]
}

resource "aws_route53_record" "host_air_csw-01_venue_rubykaigi_net_CNAME" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "air.csw-01.venue.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "vlan-200.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_254_2_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "254.2.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "vlan-200.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_vlan-300_csw-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "vlan-300.csw-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.1.254",
  ]
}

resource "aws_route53_record" "host_life_csw-01_venue_rubykaigi_net_CNAME" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "life.csw-01.venue.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "vlan-300.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_254_1_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "254.1.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "vlan-300.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_vlan-410_csw-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "vlan-410.csw-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.21.254",
  ]
}

resource "aws_route53_record" "host_cast_csw-01_venue_rubykaigi_net_CNAME" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "cast.csw-01.venue.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "vlan-410.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_254_21_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "254.21.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "vlan-410.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_vlan-400_csw-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "vlan-400.csw-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.79.254",
  ]
}

resource "aws_route53_record" "host_usr_csw-01_venue_rubykaigi_net_CNAME" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "usr.csw-01.venue.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "vlan-400.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_254_79_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "254.79.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "vlan-400.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_ge-0-0-22_csw-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "ge-0-0-22.csw-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.94",
  ]
}

resource "aws_route53_record" "host_94_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "94.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "ge-0-0-22.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_ge-0-0-23_csw-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "ge-0-0-23.csw-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.98",
  ]
}

resource "aws_route53_record" "host_98_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "98.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "ge-0-0-23.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_19_0_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "19.0.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gw-01.tmp.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gw-01_tmp_dualstack_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "gw-01.tmp.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.19",
  ]
}

resource "aws_route53_record" "host_gw-01_tmp_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "gw-01.tmp.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.19",
  ]
}

resource "aws_route53_record" "host_tmp_gw-01_tmp_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tmp.gw-01.tmp.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.19",
  ]
}

resource "aws_route53_record" "host_lo_gw-01_tmp_rubykaigi_net_CNAME" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "lo.gw-01.tmp.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "tmp.gw-01.tmp.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun19_gw-01_tmp_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun19.gw-01.tmp.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.14",
  ]
}

resource "aws_route53_record" "host_14_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "14.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun19.gw-01.tmp.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_csw-01_venue_dualstack_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "csw-01.venue.dualstack.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:0df0:8500:cab0::a",
  ]
}

resource "aws_route53_record" "host_vlan-1000_csw-01_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "vlan-1000.csw-01.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:0df0:8500:cab0::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_b_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.b.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "vlan-1000.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_vlan-200_csw-01_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "vlan-200.csw-01.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:0df0:8500:cab1::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_1_b_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.1.b.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "vlan-200.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_vlan-300_csw-01_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "vlan-300.csw-01.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:0df0:8500:caa0::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_a_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.a.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "vlan-300.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_vlan-410_csw-01_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "vlan-410.csw-01.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:0df0:8500:caa1::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_1_a_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.1.a.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "vlan-410.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_vlan-400_csw-01_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "vlan-400.csw-01.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:0df0:8500:caaa::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_a_a_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.a.a.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "vlan-400.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_ge-0-0-22_csw-01_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "ge-0-0-22.csw-01.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:9394::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_4_9_3_9_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.4.9.3.9.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "ge-0-0-22.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_ge-0-0-23_csw-01_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "ge-0-0-23.csw-01.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:9798::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_8_9_7_9_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.8.9.7.9.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "ge-0-0-23.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_2_100_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "2.100.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "wlc-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_wlc-01_venue_dualstack_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "wlc-01.venue.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.2",
  ]
}

resource "aws_route53_record" "host_wlc-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "wlc-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.2",
  ]
}

resource "aws_route53_record" "host_svc_wlc-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "svc.wlc-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.2",
  ]
}

resource "aws_route53_record" "host_mgmt_wlc-01_venue_rubykaigi_net_CNAME" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "mgmt.wlc-01.venue.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "svc.wlc-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_management_wlc-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "management.wlc-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.2.2",
  ]
}

resource "aws_route53_record" "host_air_wlc-01_venue_rubykaigi_net_CNAME" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "air.wlc-01.venue.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "management.wlc-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_2_2_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "2.2.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "management.wlc-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_110_100_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "110.100.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "sw-tra-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_sw-tra-01_venue_dualstack_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "sw-tra-01.venue.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.110",
  ]
}

resource "aws_route53_record" "host_sw-tra-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "sw-tra-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.110",
  ]
}

resource "aws_route53_record" "host_vlan1000_sw-tra-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "vlan1000.sw-tra-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.110",
  ]
}

resource "aws_route53_record" "host_mgmt_sw-tra-01_venue_rubykaigi_net_CNAME" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "mgmt.sw-tra-01.venue.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "vlan1000.sw-tra-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_111_100_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "111.100.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "sw-tra-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_sw-tra-02_venue_dualstack_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "sw-tra-02.venue.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.111",
  ]
}

resource "aws_route53_record" "host_sw-tra-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "sw-tra-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.111",
  ]
}

resource "aws_route53_record" "host_vlan1000_sw-tra-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "vlan1000.sw-tra-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.111",
  ]
}

resource "aws_route53_record" "host_mgmt_sw-tra-02_venue_rubykaigi_net_CNAME" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "mgmt.sw-tra-02.venue.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "vlan1000.sw-tra-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_115_100_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "115.100.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "sw-foa-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_sw-foa-01_venue_dualstack_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "sw-foa-01.venue.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.115",
  ]
}

resource "aws_route53_record" "host_sw-foa-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "sw-foa-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.115",
  ]
}

resource "aws_route53_record" "host_vlan1000_sw-foa-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "vlan1000.sw-foa-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.115",
  ]
}

resource "aws_route53_record" "host_mgmt_sw-foa-01_venue_rubykaigi_net_CNAME" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "mgmt.sw-foa-01.venue.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "vlan1000.sw-foa-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_120_100_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "120.100.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "sw-trb-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_sw-trb-01_venue_dualstack_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "sw-trb-01.venue.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.120",
  ]
}

resource "aws_route53_record" "host_sw-trb-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "sw-trb-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.120",
  ]
}

resource "aws_route53_record" "host_vlan1000_sw-trb-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "vlan1000.sw-trb-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.120",
  ]
}

resource "aws_route53_record" "host_mgmt_sw-trb-01_venue_rubykaigi_net_CNAME" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "mgmt.sw-trb-01.venue.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "vlan1000.sw-trb-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_121_100_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "121.100.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "sw-trb-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_sw-trb-02_venue_dualstack_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "sw-trb-02.venue.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.121",
  ]
}

resource "aws_route53_record" "host_sw-trb-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "sw-trb-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.121",
  ]
}

resource "aws_route53_record" "host_vlan1000_sw-trb-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "vlan1000.sw-trb-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.121",
  ]
}

resource "aws_route53_record" "host_mgmt_sw-trb-02_venue_rubykaigi_net_CNAME" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "mgmt.sw-trb-02.venue.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "vlan1000.sw-trb-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_125_100_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "125.100.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "sw-fob-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_sw-fob-01_venue_dualstack_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "sw-fob-01.venue.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.125",
  ]
}

resource "aws_route53_record" "host_sw-fob-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "sw-fob-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.125",
  ]
}

resource "aws_route53_record" "host_vlan1000_sw-fob-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "vlan1000.sw-fob-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.125",
  ]
}

resource "aws_route53_record" "host_mgmt_sw-fob-01_venue_rubykaigi_net_CNAME" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "mgmt.sw-fob-01.venue.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "vlan1000.sw-fob-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_130_100_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "130.100.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "sw-org-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_sw-org-01_venue_dualstack_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "sw-org-01.venue.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.130",
  ]
}

resource "aws_route53_record" "host_sw-org-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "sw-org-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.130",
  ]
}

resource "aws_route53_record" "host_vlan1000_sw-org-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "vlan1000.sw-org-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.130",
  ]
}

resource "aws_route53_record" "host_mgmt_sw-org-01_venue_rubykaigi_net_CNAME" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "mgmt.sw-org-01.venue.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "vlan1000.sw-org-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_140_100_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "140.100.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "sw-exp-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_sw-exp-01_venue_dualstack_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "sw-exp-01.venue.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.140",
  ]
}

resource "aws_route53_record" "host_sw-exp-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "sw-exp-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.140",
  ]
}

resource "aws_route53_record" "host_vlan1000_sw-exp-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "vlan1000.sw-exp-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.140",
  ]
}

resource "aws_route53_record" "host_mgmt_sw-exp-01_venue_rubykaigi_net_CNAME" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "mgmt.sw-exp-01.venue.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "vlan1000.sw-exp-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_150_100_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "150.100.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "sw-con-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_sw-con-01_venue_dualstack_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "sw-con-01.venue.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.150",
  ]
}

resource "aws_route53_record" "host_sw-con-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "sw-con-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.150",
  ]
}

resource "aws_route53_record" "host_vlan1000_sw-con-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "vlan1000.sw-con-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.150",
  ]
}

resource "aws_route53_record" "host_mgmt_sw-con-01_venue_rubykaigi_net_CNAME" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "mgmt.sw-con-01.venue.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "vlan1000.sw-con-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_2_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "2.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "dxvif-a.apne1.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_dxvif-a_apne1_dualstack_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "dxvif-a.apne1.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.2",
  ]
}

resource "aws_route53_record" "host_dxvif-a_apne1_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "dxvif-a.apne1.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.2",
  ]
}

resource "aws_route53_record" "host_dxvif-fgoavd8q_dxvif-a_apne1_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "dxvif-fgoavd8q.dxvif-a.apne1.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.2",
  ]
}

resource "aws_route53_record" "host_6_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "6.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "dxvif-b.apne1.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_dxvif-b_apne1_dualstack_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "dxvif-b.apne1.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.6",
  ]
}

resource "aws_route53_record" "host_dxvif-b_apne1_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "dxvif-b.apne1.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.6",
  ]
}

resource "aws_route53_record" "host_dxvif-fglt2p46_dxvif-b_apne1_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "dxvif-fglt2p46.dxvif-b.apne1.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.6",
  ]
}

resource "aws_route53_record" "host_10_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "10.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "vpn.apne1.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_vpn_apne1_dualstack_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "vpn.apne1.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.10",
  ]
}

resource "aws_route53_record" "host_vpn_apne1_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "vpn.apne1.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.10",
  ]
}

resource "aws_route53_record" "host_a_vpn_apne1_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "a.vpn.apne1.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.10",
  ]
}

resource "aws_route53_record" "host_br-01_hnd_dualstack_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "br-01.hnd.dualstack.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:1718::a",
  ]
}

resource "aws_route53_record" "host_tun8_br-01_hnd_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "tun8.br-01.hnd.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:1718::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_8_1_7_1_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.8.1.7.1.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun8.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi0_br-01_hnd_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bvi0.br-01.hnd.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:3738::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_8_3_7_3_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.8.3.7.3.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi0.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi1_br-01_hnd_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bvi1.br-01.hnd.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:4142::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_2_4_1_4_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.2.4.1.4.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi1.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun100_br-01_hnd_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "tun100.br-01.hnd.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:4546::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_6_4_5_4_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.6.4.5.4.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun100.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun101_br-01_hnd_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "tun101.br-01.hnd.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:4950::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_0_5_9_4_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.0.5.9.4.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun101.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi10_br-01_hnd_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bvi10.br-01.hnd.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:6970::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_0_7_9_6_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.0.7.9.6.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi10.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi11_br-01_hnd_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bvi11.br-01.hnd.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:7374::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_4_7_3_7_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.4.7.3.7.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi11.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun110_br-01_hnd_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "tun110.br-01.hnd.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:7778::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_8_7_7_7_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.8.7.7.7.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun110.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun111_br-01_hnd_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "tun111.br-01.hnd.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:8182::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_2_8_1_8_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.2.8.1.8.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun111.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gi3-0_br-01_hnd_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "gi3-0.br-01.hnd.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:0df0:8500:ca2a::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_a_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.a.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi3-0.br-01.hnd.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_br-01_itm_dualstack_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "br-01.itm.dualstack.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:1718::b",
  ]
}

resource "aws_route53_record" "host_tun8_br-01_itm_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "tun8.br-01.itm.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:1718::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_8_1_7_1_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.8.1.7.1.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun8.br-01.itm.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi0_br-01_itm_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bvi0.br-01.itm.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:2122::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_2_2_1_2_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.2.2.1.2.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi0.br-01.itm.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi1_br-01_itm_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bvi1.br-01.itm.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:2526::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_6_2_5_2_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.6.2.5.2.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi1.br-01.itm.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun100_br-01_itm_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "tun100.br-01.itm.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:2930::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_0_3_9_2_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.0.3.9.2.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun100.br-01.itm.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun101_br-01_itm_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "tun101.br-01.itm.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:3334::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_4_3_3_3_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.4.3.3.3.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun101.br-01.itm.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi10_br-01_itm_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bvi10.br-01.itm.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:5354::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_4_5_3_5_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.4.5.3.5.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi10.br-01.itm.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi11_br-01_itm_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bvi11.br-01.itm.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:5758::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_8_5_7_5_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.8.5.7.5.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi11.br-01.itm.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun110_br-01_itm_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "tun110.br-01.itm.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:6162::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_2_6_1_6_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.2.6.1.6.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun110.br-01.itm.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun111_br-01_itm_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "tun111.br-01.itm.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:6566::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_6_6_5_6_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.6.6.5.6.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun111.br-01.itm.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gi3-0_br-01_itm_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "gi3-0.br-01.itm.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:0df0:8500:ca2b::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_b_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.b.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi3-0.br-01.itm.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun-01_venue_dualstack_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "tun-01.venue.dualstack.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:2122::b",
  ]
}

resource "aws_route53_record" "host_bvi10_tun-01_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bvi10.tun-01.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:2122::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_2_2_1_2_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.2.2.1.2.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi10.tun-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi11_tun-01_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bvi11.tun-01.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:2526::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_6_2_5_2_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.6.2.5.2.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi11.tun-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun110_tun-01_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "tun110.tun-01.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:2930::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_0_3_9_2_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.0.3.9.2.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun110.tun-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun111_tun-01_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "tun111.tun-01.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:3334::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_4_3_3_3_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.4.3.3.3.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun111.tun-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi0_tun-01_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bvi0.tun-01.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:3738::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_8_3_7_3_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.8.3.7.3.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi0.tun-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi1_tun-01_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bvi1.tun-01.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:4142::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_2_4_1_4_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.2.4.1.4.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi1.tun-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun100_tun-01_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "tun100.tun-01.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:4546::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_6_4_5_4_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.6.4.5.4.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun100.tun-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun101_tun-01_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "tun101.tun-01.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:4950::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_0_5_9_4_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.0.5.9.4.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun101.tun-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gi1-1_tun-01_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "gi1-1.tun-01.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:8586::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_6_8_5_8_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.6.8.5.8.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi1-1.tun-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gi1-2_tun-01_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "gi1-2.tun-01.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:a1a2::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_2_a_1_a_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.2.a.1.a.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi1-2.tun-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun-02_venue_dualstack_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "tun-02.venue.dualstack.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:5354::b",
  ]
}

resource "aws_route53_record" "host_bvi10_tun-02_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bvi10.tun-02.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:5354::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_4_5_3_5_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.4.5.3.5.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi10.tun-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi11_tun-02_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bvi11.tun-02.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:5758::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_8_5_7_5_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.8.5.7.5.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi11.tun-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun110_tun-02_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "tun110.tun-02.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:6162::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_2_6_1_6_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.2.6.1.6.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun110.tun-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun111_tun-02_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "tun111.tun-02.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:6566::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_6_6_5_6_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.6.6.5.6.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun111.tun-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi0_tun-02_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bvi0.tun-02.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:6970::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_0_7_9_6_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.0.7.9.6.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi0.tun-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_bvi1_tun-02_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bvi1.tun-02.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:7374::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_4_7_3_7_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.4.7.3.7.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "bvi1.tun-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun100_tun-02_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "tun100.tun-02.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:7778::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_8_7_7_7_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.8.7.7.7.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun100.tun-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_tun101_tun-02_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "tun101.tun-02.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:8182::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_2_8_1_8_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.2.8.1.8.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tun101.tun-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gi1-1_tun-02_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "gi1-1.tun-02.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:8990::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_0_9_9_8_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.0.9.9.8.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi1-1.tun-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gi1-2_tun-02_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "gi1-2.tun-02.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:a5a6::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_6_a_5_a_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.6.a.5.a.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi1-2.tun-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gw-01_venue_dualstack_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "gw-01.venue.dualstack.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:8586::b",
  ]
}

resource "aws_route53_record" "host_gi0-1_gw-01_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "gi0-1.gw-01.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:8586::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_6_8_5_8_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.6.8.5.8.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi0-1.gw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gi1-1-0_gw-01_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "gi1-1-0.gw-01.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:9394::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_4_9_3_9_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.4.9.3.9.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi1-1-0.gw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gi0-2_gw-01_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "gi0-2.gw-01.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:a1a2::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_2_a_1_a_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.2.a.1.a.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi0-2.gw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gw-02_venue_dualstack_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "gw-02.venue.dualstack.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:8990::b",
  ]
}

resource "aws_route53_record" "host_gi0-1_gw-02_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "gi0-1.gw-02.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:8990::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_0_9_9_8_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.0.9.9.8.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi0-1.gw-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gi1-1-0_gw-02_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "gi1-1-0.gw-02.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:9798::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_8_9_7_9_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.8.9.7.9.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi1-1-0.gw-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_gi0-2_gw-02_venue_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "gi0-2.gw-02.venue.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:df0:8500:ca22:a5a6::b",
  ]
}

resource "aws_route53_record" "host_b_0_0_0_0_0_0_0_0_0_0_0_6_a_5_a_2_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "b.0.0.0.0.0.0.0.0.0.0.0.6.a.5.a.2.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi0-2.gw-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_152_220_50_192_reverse_rubykaigi_net_PTR" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "152.220.50.192.reverse.rubykaigi.net"
  type = "PTR"
  ttl  = 60
  records = [
    "mahiru-kmc.transit.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_mahiru-kmc_transit_dualstack_rubykaigi_net_A" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "mahiru-kmc.transit.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "192.50.220.152",
  ]
}

resource "aws_route53_record" "host_mahiru-kmc_transit_rubykaigi_net_A" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "mahiru-kmc.transit.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "192.50.220.152",
  ]
}

resource "aws_route53_record" "host_enx_mahiru-kmc_transit_rubykaigi_net_A" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "enx.mahiru-kmc.transit.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "192.50.220.152",
  ]
}

resource "aws_route53_record" "host_bb_mahiru-kmc_transit_rubykaigi_net_CNAME" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bb.mahiru-kmc.transit.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "enx.mahiru-kmc.transit.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_154_220_50_192_reverse_rubykaigi_net_PTR" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "154.220.50.192.reverse.rubykaigi.net"
  type = "PTR"
  ttl  = 60
  records = [
    "yume-kmc.transit.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_yume-kmc_transit_dualstack_rubykaigi_net_A" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "yume-kmc.transit.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "192.50.220.154",
  ]
}

resource "aws_route53_record" "host_yume-kmc_transit_rubykaigi_net_A" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "yume-kmc.transit.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "192.50.220.154",
  ]
}

resource "aws_route53_record" "host_tba_yume-kmc_transit_rubykaigi_net_A" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "tba.yume-kmc.transit.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "192.50.220.154",
  ]
}

resource "aws_route53_record" "host_bb_yume-kmc_transit_rubykaigi_net_CNAME" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bb.yume-kmc.transit.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "tba.yume-kmc.transit.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_156_220_50_192_reverse_rubykaigi_net_PTR" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "156.220.50.192.reverse.rubykaigi.net"
  type = "PTR"
  ttl  = 60
  records = [
    "nat-0a31cfd416018b27c.apne1.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_nat-0a31cfd416018b27c_apne1_dualstack_rubykaigi_net_A" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "nat-0a31cfd416018b27c.apne1.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "192.50.220.156",
  ]
}

resource "aws_route53_record" "host_nat-0a31cfd416018b27c_apne1_rubykaigi_net_A" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "nat-0a31cfd416018b27c.apne1.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "192.50.220.156",
  ]
}

resource "aws_route53_record" "host_outer_nat-0a31cfd416018b27c_apne1_rubykaigi_net_A" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "outer.nat-0a31cfd416018b27c.apne1.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "192.50.220.156",
  ]
}

resource "aws_route53_record" "host_bb_nat-0a31cfd416018b27c_apne1_rubykaigi_net_CNAME" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bb.nat-0a31cfd416018b27c.apne1.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "outer.nat-0a31cfd416018b27c.apne1.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_157_220_50_192_reverse_rubykaigi_net_PTR" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "157.220.50.192.reverse.rubykaigi.net"
  type = "PTR"
  ttl  = 60
  records = [
    "nat-038c99fc6c04e2fcc.apne1.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_nat-038c99fc6c04e2fcc_apne1_dualstack_rubykaigi_net_A" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "nat-038c99fc6c04e2fcc.apne1.dualstack.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "192.50.220.157",
  ]
}

resource "aws_route53_record" "host_nat-038c99fc6c04e2fcc_apne1_rubykaigi_net_A" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "nat-038c99fc6c04e2fcc.apne1.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "192.50.220.157",
  ]
}

resource "aws_route53_record" "host_outer_nat-038c99fc6c04e2fcc_apne1_rubykaigi_net_A" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "outer.nat-038c99fc6c04e2fcc.apne1.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "192.50.220.157",
  ]
}

resource "aws_route53_record" "host_bb_nat-038c99fc6c04e2fcc_apne1_rubykaigi_net_CNAME" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "bb.nat-038c99fc6c04e2fcc.apne1.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "outer.nat-038c99fc6c04e2fcc.apne1.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_mahiru-kmc_transit_dualstack_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "mahiru-kmc.transit.dualstack.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:0df0:8500:ca2a::a",
  ]
}

resource "aws_route53_record" "host_enx_mahiru-kmc_transit_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "enx.mahiru-kmc.transit.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:0df0:8500:ca2a::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_a_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.a.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "enx.mahiru-kmc.transit.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_yume-kmc_transit_dualstack_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "yume-kmc.transit.dualstack.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:0df0:8500:ca2b::a",
  ]
}

resource "aws_route53_record" "host_tba_yume-kmc_transit_rubykaigi_net_AAAA" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "tba.yume-kmc.transit.rubykaigi.net"
  type = "AAAA"
  ttl  = 60
  records = [
    "2001:0df0:8500:ca2b::a",
  ]
}

resource "aws_route53_record" "host_a_0_0_0_0_0_0_0_0_0_0_0_0_0_0_0_b_2_a_c_0_0_5_8_0_f_d_0_1_0_0_2_ip6_arpa_PTR" {
  zone_id = aws_route53_zone.ptr-ip6.zone_id

  name = "a.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.b.2.a.c.0.0.5.8.0.f.d.0.1.0.0.2.ip6.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "tba.yume-kmc.transit.rubykaigi.net.",
  ]
}
