{
  search_domains: ['on.rubykaigi.net'],
  dns_resolvers: ['10.33.136.53', '10.33.152.53'],  // origin.resolver.rubykaigi.net?
  dns_resolvers_usr: ['192.50.220.164', '192.50.220.165'],  // resolver.rubykaigi.net
  ntp_servers: ['216.239.35.0', '216.239.35.4', '216.239.35.8', '216.239.35.12'],  // time.google.com

  tftp_server: '10.33.136.67',
  syslog_server: '10.33.136.14',
  pxe_client_classes: ['pxe_ipxe', 'pxe_uefi'],
}
