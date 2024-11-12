[
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'v6test',
      labels: {
        'rubykaigi.org/app': 'v6test',
      },
    },
    spec: {
      replicas: 1,
      selector: {
        matchLabels: { 'rubykaigi.org/app': 'v6test' },
      },
      template: {
        metadata: {
          labels: { 'rubykaigi.org/app': 'v6test' },
        },
        spec: {
          nodeSelector: {
            'rubykaigi.org/node-group': 'onpremises',
          },
          tolerations: [
            { key: 'dedicated', value: 'onpremises', effect: 'NoSchedule' },
          ],
          containers: [
            {
              name: 'frr',
              image: 'quay.io/frrouting/frr:9.1.0',
              command: [
                '/bin/bash',
                '-xe',
                '-c',
                |||
                  if ! ip link show dev vxlan-66; then
                    underlay_iface=eth0
                    local_addr=$(ip -br addr show "$underlay_iface" | awk 'match($0, /10\.33\.\d+\.\d+/) { print substr($0, RSTART, RLENGTH) }')
                    ip link add vxlan-66 type vxlan id 66 local "$local_addr" dstport 4789 nolearning dev "$underlay_iface"
                    ip link add br-66 type bridge stp_state 0
                    ip link set up br-66
                    ip link set up vxlan-66 master br-66 addrgenmode none
                    ip addr add 2001:df0:8500:ca60::"$local_addr"/64 dev br-66
                    ip route add default via 2001:df0:8500:ca60::a21:88b6
                  fi

                  ln -sf /config/frr/frr.conf /etc/frr/
                  sed -i 's|bgpd=no|bgpd=yes|' /etc/frr/daemons
                  exec /usr/lib/frr/docker-start
                |||,
              ],
              securityContext: {
                capabilities: { add: ['SYS_ADMIN', 'NET_ADMIN'] },
              },
              volumeMounts: [
                { name: 'frr-config', mountPath: '/config/frr', readOnly: false },
              ],
            },
            {
              name: 'v6test',
              image: 'public.ecr.aws/docker/library/debian:stable',
              command: ['/bin/sleep', '1d'],
              securityContext: {
                capabilities: { add: ['NET_ADMIN'] },
              },
            },
          ],
          volumes: [
            {
              name: 'frr-config',
              configMap: {
                name: 'v6test-frr-config',
              },
            },
          ],
        },
      },
    },
  },
]
