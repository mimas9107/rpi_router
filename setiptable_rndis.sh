# 建立 NAT 轉發，從 wlan0 → eth0
sudo iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
sudo iptables -A FORWARD -i eth1 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT

# 儲存設定
sudo apt install iptables-persistent
sudo netfilter-persistent save

