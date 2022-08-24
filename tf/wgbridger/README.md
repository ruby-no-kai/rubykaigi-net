# wgbridger

build L2 bridge using Wireguard to bring NGN to behind IPv4 NAPT only environment...

- Put intermediate node available in dualstack with higher MTU, such as AWS EC2
  - relay packet arrived on wg0 to another peer on wg0
- A and Z node are connected with vxlan and Linux bridge
- A node delivers NGN to Z node through vxlan on wg0

```
NGN (eth0) <= br0 on A => vxlan0 on A <= wg0 => I <= wg0 => vxlan0 on Z <= br0 on Z => (enx) routers to provision
```

- A side: Directly attached to NGN (w/ VNE enabled)
- Intermediate: AWS EC2 (dualstack)
- Z side: IPv4 network behind NAT

## Setup

```
cp itamae/data.example.rb itamae/data.rb
vim itamae/data.rb

./itamae-apply.sh a [ssh arguments to A node]
./itamae-apply.sh i [ssh arguments to I node]
./itamae-apply.sh z [ssh arguments to Z node]
# e.g. ./itamae-apply.sh i -J bastion.xxx -p NNN i-node.example.com
```

## Using Wi-Fi

- While I and A nodes eliminate netplan, Z node is still enabled for eth0 and wlan0. Configure `/etc/netplan/*.yml` as much as you like to connect to Wi-Fi using NetworkManager. Note that sd-networkd still has to be kept enabled for managing wg0, vxlan0, and br0
- All nodes will disable cloud-init network configuration module.
