#!/usr/bin/env bash
# Run as root on the Coolify host (Coolify > Servers > localhost > Terminal, or SSH).
# Opens the RustDesk ports in the host firewall. Oracle Cloud images ship iptables
# rules that reject everything but SSH, so the ACCEPT rules go before them.
set -euo pipefail

add() {
  iptables -C INPUT -p "$1" --dport "$2" -j ACCEPT 2>/dev/null || iptables -I INPUT 5 -p "$1" --dport "$2" -j ACCEPT
}
add tcp 21115:21119
add udp 21116

if command -v netfilter-persistent >/dev/null; then
  netfilter-persistent save
elif command -v ufw >/dev/null && ufw status | grep -q active; then
  ufw allow 21115:21119/tcp
  ufw allow 21116/udp
fi
echo "Ports open. On Oracle Cloud also add the same ingress rules to the VCN Security List."
