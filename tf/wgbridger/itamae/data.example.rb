node.reverse_merge!(
  wgbridger: {
    nodes: {
      # private=`wg genkey` public=`wg pubkey`, inner=wg0 iface IP address /32, endpoint=known address to connect, out_mac=Z side bridge port iface MAC address
      a: {private: '', public: '', inner: '100.64.187.1'},
      i: {private: '', public: '', inner: '100.64.187.2', endpoint: 'wgbridger.rubykaigi.net'},
      z: {private: '', public: '', inner: '100.64.187.3', out_mac: '40:3c:fc:01:aa:ee'},
    },
  },
)
node.reverse_merge!(
  wgbridger: {
    i: node.fetch(:wgbridger).fetch(:nodes).fetch(:i),
  },
)

