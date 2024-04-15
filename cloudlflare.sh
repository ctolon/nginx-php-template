#!/bin/bash

# https://upcloud.com/resources/tutorials/configure-iptables-ubuntu
set -eo pipefail

epoch=$(date +%s)

# Backup the current rules
mkdir -pv ./rules-backup
cp /etc/iptables/rules.v4 ./rules-backup/rules.v4.$epoch

# https://www.cloudflare.com/ips
# https://support.cloudflare.com/hc/en-us/articles/200169166-How-do-I-whitelist-CloudFlare-s-IP-addresses-in-iptables-

for i in $(curl https://www.cloudflare.com/ips-v4); do iptables -I INPUT -p tcp -m multiport --dports http,https -s $i -j ACCEPT; done
for i in $(curl https://www.cloudflare.com/ips-v6); do ip6tables -I INPUT -p tcp -m multiport --dports http,https -s $i -j ACCEPT; done

# Add Special IPs
specific_ips=('IP LIST')
for i in "${specific_ips[@]}"; do iptables -I INPUT -p tcp -m multiport --dports http,https -s $i -j ACCEPT; done

# Avoid racking up billing/attacks
# WARNING: If you get attacked and CloudFlare drops you, your site(s) will be unreachable. 
iptables -A INPUT -p tcp -m multiport --dports http,https -j DROP
ip6tables -A INPUT -p tcp -m multiport --dports http,https -j DROP

# WARNING: This does NOT block Cloudflare's clients from accessing your website over HTTP or HTTPS with a Cloudflare Worker.

# Save the rules as persistent
iptables-save > /etc/iptables/rules.v4

# For restore
#sudo iptables-restore < /etc/iptables/rules.v4
