#!/bin/bash

echo "[---Begin consul-auto-join.sh---]"
local_private_ipv4=$(ip route get 8.8.8.8 | awk '{print $NF; exit}')
public_ipv4=$(curl http://checkip.amazonaws.com)
echo "local_private_ipv4=$local_private_ipv4"
echo "public_ipv4=$public_ipv4"

# stop consul so it can be configured correctly
systemctl stop consul

# clear the consul data directory ready for a fresh start
rm -rf /opt/consul/data/*

jq ".retry_join += [\"provider=azure resource_group=${name} vm_scale_set=${name} subscription_id=${azure_subscription_id} tenant_id=${azure_tenant_id} client_id=${azure_client_id} secret_access_key=${azure_client_secret}\"]" < /etc/consul.d/default.json > /tmp/default.json.tmp
jq ".advertise_addr = \"$local_private_ipv4\"" < /tmp/default.json.tmp > /tmp/default.json.tmp.2

cp /tmp/default.json.tmp.2 /tmp/inspect.json
mv /tmp/default.json.tmp.2 /etc/consul.d/default.json
chown consul:consul /etc/consul.d/default.json

# start consul once it is configured correctly
systemctl start consul

echo "[---consul-auto-join.sh Complete---]"