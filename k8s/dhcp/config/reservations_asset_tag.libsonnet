// Cisco devices prepend NUL (\u0000) to the ASCII client-id they send, so the
// DHCP server must match on "'\u0000<tag>'". Keep the table below NUL-free and
// let clientId() apply the prefix.
local clientId(tag) = "'" + std.char(0) + tag + "'";

local tags = [
  { tag: 'rk-srn19a1', octet: 80 },
  { tag: 'rk-srn19a2', octet: 81 },
  { tag: 'rk-srnp19a1', octet: 82 },
  { tag: 'rk-srnp19a2', octet: 83 },
  { tag: 'rk-srnp19a3', octet: 84 },
  { tag: 'rk-srnp19a4', octet: 85 },
  { tag: 'rk-srnp19a5', octet: 86 },
  { tag: 'rk-srnp19a6', octet: 87 },
  { tag: 'rk-srnp19a7', octet: 88 },
  { tag: 'rk-srnp19a8', octet: 89 },
  { tag: 'rk-srhp25a1', octet: 90 },
  { tag: 'rk-srhp25a2', octet: 91 },
  { tag: 'rk-srhp25a3', octet: 92 },
  { tag: 'rk-srhp25a4', octet: 93 },
  { tag: 'rk-srnp25a1', octet: 94 },
];

function(prefix) std.map(
  function(e) {
    'client-id': clientId(e.tag),
    'ip-address': prefix + '.' + e.octet,
  },
  tags,
)
