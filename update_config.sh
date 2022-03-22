#!/bin/sh

IP=$(wget -qO- "$BALENA_SUPERVISOR_ADDRESS/v1/device?apikey=$BALENA_SUPERVISOR_API_KEY"| jq -r .ip_address)

# if it is not already configured
if ! ipfs config API.HTTPHeaders.Access-Control-Allow-Origin| grep -q "$IP";
then
  NAME=$(wget -qO- "$BALENA_SUPERVISOR_ADDRESS/v1/device/host-config?apikey=$BALENA_SUPERVISOR_API_KEY"| jq -r .network.hostname)
  echo "configuring..."

  #format proper json attributes
  JSON_FMT='["http://%s:5001", "http://%s.local:5001", "http://localhost:3000", "http://127.0.0.1:5001", "https://webui.ipfs.io"]'
  JSON_STRING=$(printf "$JSON_FMT" "$IP" "$NAME")

  ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin "$JSON_STRING"
  ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "POST"]'
  #restart
  echo "restarting"
  ipfs shutdown
else
  echo "already configured"
fi
