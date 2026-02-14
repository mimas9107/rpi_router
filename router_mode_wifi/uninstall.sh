#!/bin/bash

# RPi Router (WiFi to Ethernet) Uninstaller
# This script reverts the changes made by install.sh.

# Stop on any error
set -e

# --- Configuration (must match install.sh) ---
NMCLI_CONNECTION_NAME="rpi-router-lan"

# --- Main Script ---

echo "🗑️ Starting Raspberry Pi WiFi Router Uninstallation..."

# 1. Stop and remove dnsmasq
echo "🛑 Stopping and removing dnsmasq..."
sudo systemctl stop dnsmasq || echo "dnsmasq was not running."
sudo apt-get purge -y dnsmasq

# 2. Remove the static IP configuration
echo "⚙️ Removing static IP configuration..."
if nmcli con show "$NMCLI_CONNECTION_NAME" > /dev/null 2>&1; then
    sudo nmcli con delete "$NMCLI_CONNECTION_NAME"
    echo "Removed nmcli connection profile '${NMCLI_CONNECTION_NAME}'."
else
    echo "No nmcli connection profile found with the name '${NMCLI_CONNECTION_NAME}'. Nothing to do."
fi

# 3. Disable IP forwarding
echo "🚦 Disabling IP forwarding..."
# This is safer than deleting the line, as the original file may have it commented or uncommented.
# We will comment it out.
sudo sed -i '/^net.ipv4.ip_forward=1/c\#net.ipv4.ip_forward=1' /etc/sysctl.conf
sudo sysctl -p

# 4. Flush iptables rules and save
echo "🔥 Flushing all iptables rules..."
sudo iptables -F
sudo iptables -t nat -F
sudo iptables -X
echo "💾 Saving empty ruleset..."
sudo netfilter-persistent save

# 5. Remove unused packages
echo "🧹 Cleaning up dependencies..."
sudo apt-get autoremove -y

echo ""
echo "✅ Uninstallation complete."
echo "The Raspberry Pi has been reverted to its previous state."
echo "You may need to restart your networking service or reboot for all changes to take full effect."
echo "Run 'sudo systemctl restart networking' or 'sudo reboot'."
