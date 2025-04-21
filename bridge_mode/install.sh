#!/bin/bash

# 更新系統
echo "Updating the system..."
sudo apt update && sudo apt upgrade -y

# 安裝必要套件
echo "Installing necessary packages..."
sudo apt install -y bridge-utils iptables-persistent

# 創建網路橋接接口
echo "Creating network bridge..."
sudo brctl addbr br0
sudo brctl addif br0 wlan0
sudo brctl addif br0 eth0

# 設定靜態 IP 給 br0
echo "Configuring static IP for bridge (br0)..."
echo "
auto lo
iface lo inet loopback

iface wlan0 inet manual
iface eth0 inet manual

auto br0
iface br0 inet static
    address 192.168.1.1
    netmask 255.255.255.0
    bridge_ports wlan0 eth0
" | sudo tee /etc/network/interfaces > /dev/null

# 啟用 IP forwarding
echo "Enabling IP forwarding..."
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf > /dev/null
sudo sysctl -p

# 設置 NAT (Network Address Translation) 轉發
echo "Setting up NAT for internet sharing..."
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE

# 確保 NAT 設定在重啟後仍然有效
echo "Saving iptables NAT settings..."
sudo netfilter-persistent save

# 重啟網路服務
echo "Restarting networking service..."
sudo systemctl restart networking

# 提示完成
echo "Raspberry Pi is now configured in bridge mode. It is ready to share your mobile hotspot connection to the local network."

