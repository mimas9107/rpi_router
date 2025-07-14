#!/bin/bash

# 更新並安裝所需軟體
echo "Updating system and installing necessary packages..."
#sudo apt update
#sudo apt upgrade -y
#sudo apt install -y dnsmasq iptables-persistent net-tools

# 設定 eth0 靜態 IP
echo "Setting static IP for eth0..."
nmcli con add type ethernet ifname eth0 con-name bridge-eth0 autoconnect yes ip4 192.168.88.1/24
nmcli con up bridge-eth0

# 配置 dnsmasq 作為 DHCP server
echo "Configuring dnsmasq as DHCP server..."
sudo bash -c 'cat > /etc/dnsmasq.conf << EOF
interface=eth0
dhcp-range=192.168.88.2,192.168.88.100,255.255.255.0,24h
EOF'

# 啟用 IP forwarding
echo "Enabling IP forwarding..."
sudo sed -i '/^#net.ipv4.ip_forward=1/c\net.ipv4.ip_forward=1' /etc/sysctl.conf
sudo sysctl -p

# "清除舊的 iptables NAT 規則..."
echo "清除舊的 iptables NAT 規則..."
sudo iptables -F
sudo iptables -t nat -F


# 設定 iptables NAT 轉發
echo "Setting up NAT for eth0..."
#sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
#sudo iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o usb0 -j MASQUERADE

echo "🧱 FORWARD 規則（eth0 → usb0）"
sudo iptables -A FORWARD -i eth0 -o usb0 -j ACCEPT
sudo iptables -A FORWARD -i usb0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

echo "🧱 限制服務只允許 wlan0 來源（192.168.1.0/24）..."
sudo iptables -A INPUT -i wlan0 -s 192.168.1.0/24 -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -i wlan0 -s 192.168.1.0/24 -p tcp --dport 8765 -j ACCEPT  # ICECC (如使用)
sudo iptables -A INPUT -i eth0 -p tcp --dport 22 -j DROP


# 20250429 more safety setting than above:
# iptables -A FORWARD -i eth0 -o wlan0 -j ACCEPT
# iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT
# iptables -A FORWARD -i eth0 -o usb0 -j ACCEPT
# iptables -A FORWARD -i wlan0 -o eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
# iptables -A FORWARD -i eth1 -o eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
# iptables -A FORWARD -i usb0 -o eth0 -m state --state ESTABLISHED,RELATED -j ACCEPT
# iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
# iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
# iptables -t nat -A POSTROUTING -o usb0 -j MASQUERADE

# 儲存 iptables 設定
echo "Saving iptables settings..."
sudo netfilter-persistent save

# 重啟 dnsmasq 服務
echo "Restarting dnsmasq service..."
sudo systemctl restart dnsmasq

# 顯示 eth0 和 wlan0 的 IP 配置
echo "Current IP configuration:"
ip addr show eth0
ip addr show wlan0
#ip addr show eth1
ip addr show usb0
echo "Setup complete! Your Raspberry Pi is now ready to share internet through eth0 to the router."

