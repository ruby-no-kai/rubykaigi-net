local cloud_config = (import '../cloudconfig.base.libsonnet') + {
  runcmd: [
    ['networkctl', 'reload'],
  ],
  write_files: [
    {
      path: '/etc/systemd/network/10-netplan-ens5.network.d/tun.conf',
      content: |||
        [Network]
        Tunnel=tun
      |||,
    },
    {
      path: '/etc/systemd/network/tun.netdev',
      content: |||
        # ip link add name tun type ip6tnl local 2406:da14:dfe:c0c0::30fe remote 2001:0df0:8500:ca00::1 mode any encaplimit none dev ens5
        [NetDev]
        Name=tun
        Kind=ip6tnl

        [Tunnel]
        Local=dhcp6
        Remote=2001:0df0:8500:ca00::1
        Mode=any
        EncapsulationLimit=none
      |||,
    },
    {
      path: '/etc/systemd/network/tun.network',
      content: |||
        [Match]
        Name=tun

        [Network]
        IPv6AcceptRA=no
        Address=10.33.22.241/31
        Address=2001:0df0:8500:ca22:240::b/124
        Address=192.50.220.164/32
        Address=192.50.220.165/32
        Address=2001:0df0:8500:ca6d:53::c/128
        Address=2001:0df0:8500:ca6d:53::d/128

        [Route]
        Gateway=10.33.22.240
        Table=12345

        [Route]
        Gateway=2001:0df0:8500:ca22:240::a
        Table=12345

        [RoutingPolicyRule]
        Priority=12345
        From=192.50.220.164/31
        Table=12345

        [RoutingPolicyRule]
        Priority=12345
        From=2001:0df0:8500:ca6d:53::c/127
        Table=12345
      |||,
    },
  ],
  packages: [
    'nginx',
  ],
};

{
  cloud_config: cloud_config,
  user_data: std.format('#cloud-config\n%s\n', std.manifestYamlDoc(cloud_config)),
}
