#!/bin/bash

echo "[---Begin consul-auto-join.sh---]"
local_ipv4="$(echo -e `hostname -I` | tr -d '[:space:]')"
public_address=$(curl -s http://checkip.amazonaws.com || printf "0.0.0.0")

# stop consul so it can be configured correctly
systemctl stop consul

# clear the consul data directory ready for a fresh start
rm -rf /opt/consul/data/*

jq ".retry_join += [\"provider=azure resource_group=${name} vm_scale_set=${name} subscription_id=${azure_subscription_id} tenant_id=${azure_tenant_id} client_id=${azure_client_id} secret_access_key=${azure_client_secret}\"]" < /etc/consul.d/default.json > /tmp/default.json.tmp

sed -i -e "s/127.0.0.1/$${local_ipv4}/" /tmp/default.json.tmp
mv /tmp/default.json.tmp /etc/consul.d/default.json
chown consul:consul /etc/consul.d/default.json

# start consul once it is configured correctly
systemctl start consul

echo "[---consul-auto-join.sh Complete---]"