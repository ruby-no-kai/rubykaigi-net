resource "aws_route53_record" "host_br-01_hnd_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "br-01.hnd.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.1",
  ]
}

resource "aws_route53_record" "host_1_0_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "1.0.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "br-01.hnd.rubykaigi.net.",
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

resource "aws_route53_record" "host_br-01_itm_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "br-01.itm.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.2",
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

resource "aws_route53_record" "host_tun11_br-01_itm_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun11.br-01.itm.rubykaigi.net"
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
    "tun11.br-01.itm.rubykaigi.net.",
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

resource "aws_route53_record" "host_tun-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.11",
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

resource "aws_route53_record" "host_tun-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "tun-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.12",
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

resource "aws_route53_record" "host_gw-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "gw-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.21",
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

resource "aws_route53_record" "host_lo_gw-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "lo.gw-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.0.21",
  ]
}

resource "aws_route53_record" "host_gi1-0_gw-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "gi1-0.gw-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.20.1",
  ]
}

resource "aws_route53_record" "host_ring_gw-01_venue_rubykaigi_net_CNAME" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "ring.gw-01.venue.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "gi1-0.gw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_1_20_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "1.20.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi1-0.gw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_nat_gw-01_venue_rubykaigi_net_A" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "nat.gw-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "192.50.220.158",
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

resource "aws_route53_record" "host_22_0_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "22.0.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gw-02.venue.rubykaigi.net.",
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

resource "aws_route53_record" "host_gi1-0_gw-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "gi1-0.gw-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.20.2",
  ]
}

resource "aws_route53_record" "host_ring_gw-02_venue_rubykaigi_net_CNAME" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "ring.gw-02.venue.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "gi1-0.gw-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_2_20_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "2.20.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gi1-0.gw-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_nat_gw-02_venue_rubykaigi_net_A" {
  for_each = local.rubykaigi_net_zones
  zone_id  = each.value


  name = "nat.gw-02.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "192.50.220.159",
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

resource "aws_route53_record" "host_31_0_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "31.0.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "csw-01.venue.rubykaigi.net.",
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

resource "aws_route53_record" "host_v-ring_csw-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "v-ring.csw-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.20.3",
  ]
}

resource "aws_route53_record" "host_ring_csw-01_venue_rubykaigi_net_CNAME" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "ring.csw-01.venue.rubykaigi.net"
  type = "CNAME"
  ttl  = 60
  records = [
    "v-ring.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_3_20_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "3.20.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "v-ring.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_v-mgmt_csw-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "v-mgmt.csw-01.venue.rubykaigi.net"
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
    "v-mgmt.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_1_100_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "1.100.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "v-mgmt.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_v-air_csw-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "v-air.csw-01.venue.rubykaigi.net"
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
    "v-air.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_254_2_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "254.2.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "v-air.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_v-life_csw-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "v-life.csw-01.venue.rubykaigi.net"
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
    "v-life.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_254_1_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "254.1.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "v-life.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_v-usr_csw-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "v-usr.csw-01.venue.rubykaigi.net"
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
    "v-usr.csw-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_254_79_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "254.79.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "v-usr.csw-01.venue.rubykaigi.net.",
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

resource "aws_route53_record" "host_19_0_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "19.0.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "gw-01.tmp.rubykaigi.net.",
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

resource "aws_route53_record" "host_wlc-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "wlc-01.venue.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.100.2",
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

resource "aws_route53_record" "host_sys_wlc-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "sys.wlc-01.venue.rubykaigi.net"
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
    "sys.wlc-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_2_2_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "2.2.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "sys.wlc-01.venue.rubykaigi.net.",
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

resource "aws_route53_record" "host_110_100_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "110.100.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "sw-tra-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_v-mgmt_sw-tra-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "v-mgmt.sw-tra-01.venue.rubykaigi.net"
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
    "v-mgmt.sw-tra-01.venue.rubykaigi.net.",
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

resource "aws_route53_record" "host_111_100_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "111.100.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "sw-tra-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_v-mgmt_sw-tra-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "v-mgmt.sw-tra-02.venue.rubykaigi.net"
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
    "v-mgmt.sw-tra-02.venue.rubykaigi.net.",
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

resource "aws_route53_record" "host_115_100_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "115.100.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "sw-foa-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_v-mgmt_sw-foa-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "v-mgmt.sw-foa-01.venue.rubykaigi.net"
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
    "v-mgmt.sw-foa-01.venue.rubykaigi.net.",
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

resource "aws_route53_record" "host_120_100_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "120.100.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "sw-trb-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_v-mgmt_sw-trb-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "v-mgmt.sw-trb-01.venue.rubykaigi.net"
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
    "v-mgmt.sw-trb-01.venue.rubykaigi.net.",
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

resource "aws_route53_record" "host_121_100_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "121.100.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "sw-trb-02.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_v-mgmt_sw-trb-02_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "v-mgmt.sw-trb-02.venue.rubykaigi.net"
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
    "v-mgmt.sw-trb-02.venue.rubykaigi.net.",
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

resource "aws_route53_record" "host_125_100_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "125.100.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "sw-fob-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_v-mgmt_sw-fob-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "v-mgmt.sw-fob-01.venue.rubykaigi.net"
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
    "v-mgmt.sw-fob-01.venue.rubykaigi.net.",
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

resource "aws_route53_record" "host_130_100_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "130.100.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "sw-org-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_v-mgmt_sw-org-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "v-mgmt.sw-org-01.venue.rubykaigi.net"
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
    "v-mgmt.sw-org-01.venue.rubykaigi.net.",
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

resource "aws_route53_record" "host_140_100_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "140.100.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "sw-exp-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_v-mgmt_sw-exp-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "v-mgmt.sw-exp-01.venue.rubykaigi.net"
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
    "v-mgmt.sw-exp-01.venue.rubykaigi.net.",
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

resource "aws_route53_record" "host_150_100_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "150.100.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "sw-con-01.venue.rubykaigi.net.",
  ]
}

resource "aws_route53_record" "host_v-mgmt_sw-con-01_venue_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "v-mgmt.sw-con-01.venue.rubykaigi.net"
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
    "v-mgmt.sw-con-01.venue.rubykaigi.net.",
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

resource "aws_route53_record" "host_2_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "2.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "dxvif-a.apne1.rubykaigi.net.",
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

resource "aws_route53_record" "host_dxvif-b_apne1_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "dxvif-b.apne1.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.6",
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

resource "aws_route53_record" "host_dxvif-fglt2p46_dxvif-b_apne1_rubykaigi_net_A" {
  zone_id = data.aws_route53_zone.rubykaigi-net_private.zone_id

  name = "dxvif-fglt2p46.dxvif-b.apne1.rubykaigi.net"
  type = "A"
  ttl  = 60
  records = [
    "10.33.22.6",
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

resource "aws_route53_record" "host_10_22_33_10_in-addr_arpa_PTR" {
  zone_id = data.aws_route53_zone.ptr-10.zone_id

  name = "10.22.33.10.in-addr.arpa"
  type = "PTR"
  ttl  = 60
  records = [
    "vpn.apne1.rubykaigi.net.",
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
