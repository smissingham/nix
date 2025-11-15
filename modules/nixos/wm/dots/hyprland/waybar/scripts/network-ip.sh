#!/usr/bin/env bash

# Get the default network interface
INTERFACE=$(ip route | grep '^default' | awk '{print $5}' | head -n1)

if [ -z "$INTERFACE" ]; then
    echo "󰤮 Disconnected"
    exit 0
fi

# Get IP address
IP=$(ip addr show "$INTERFACE" | grep "inet " | awk '{print $2}' | cut -d/ -f1)

printf "󰀂 %s" "$IP"
