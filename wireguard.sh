#!/bin/bash


dnf update -y
dnf install -y elrepo-release epel-release
dnf install -y kmod-wireguard wireguard-tools
sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g" /etc/sysctl.conf
sysctl -p
cd /etc/wireguard
umask 077
wg genkey | tee privatekey | wg pubkey > publickey
public=$(cat /etc/wireguard/publickey)
private=$(cat /etc/wireguard/privatekey)
cat > /etc/wireguard/wg0.conf <<EOF
[Interface]
PrivateKey = $private
Address = 192.168.0.1/24
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
ListenPort = 51820

[Peer]
PublicKey = $public
AllowedIPs = 192.168.0.2/32
EOF

systemctl enable wg-quick@wg0
