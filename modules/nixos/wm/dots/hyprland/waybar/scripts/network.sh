#!/usr/bin/env bash

# Get the default network interface
INTERFACE=$(ip route | grep '^default' | awk '{print $5}' | head -n1)

if [ -z "$INTERFACE" ]; then
    echo "󰤮 Disconnected"
    exit 0
fi

# Get IP address
IP=$(ip addr show "$INTERFACE" | grep "inet " | awk '{print $2}' | cut -d/ -f1)

# Get previous stats
PREV_RX=$(cat /tmp/waybar_rx 2>/dev/null || echo 0)
PREV_TX=$(cat /tmp/waybar_tx 2>/dev/null || echo 0)

# Get current stats (in bytes)
RX=$(cat /sys/class/net/"$INTERFACE"/statistics/rx_bytes)
TX=$(cat /sys/class/net/"$INTERFACE"/statistics/tx_bytes)

# Calculate difference and convert to MB/s (divided by interval in seconds)
INTERVAL=3
RX_RATE=$(echo "scale=2; ($RX - $PREV_RX) / $INTERVAL / 1048576" | bc)
TX_RATE=$(echo "scale=2; ($TX - $PREV_TX) / $INTERVAL / 1048576" | bc)

# Save current stats for next iteration
echo "$RX" > /tmp/waybar_rx
echo "$TX" > /tmp/waybar_tx

# Format output with fixed width
printf "󰀂 %s  |  ⇣%.2f MB/s ⇡%.2f MB/s" "$IP" "$RX_RATE" "$TX_RATE"
