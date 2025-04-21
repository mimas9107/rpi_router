#sudo iptables -A INPUT -i wlan0 -p tcp --syn -m limit --limit 1/second --limit-burst 3 -j ACCEPT
#sudo iptables -A INPUT -i wlan0 -p tcp --syn -j DROP

# 限速 TCP ACK（通常是掃 port / flood）
sudo iptables -A INPUT -i wlan0 -p tcp --tcp-flags ALL ACK -m limit --limit 1/second --limit-burst 5 -j ACCEPT
sudo iptables -A INPUT -i wlan0 -p tcp --tcp-flags ALL ACK -j DROP
sudo iptables -A INPUT -i eth1 -p tcp --tcp-flags ALL ACK -m limit --limit 1/second --limit-burst 4 -j ACCEPT
sudo iptables -A INPUT -i eth1 -p tcp --tcp-flags ALL ACK -j DROP

# UDP 限速（避免 flood）
sudo iptables -A INPUT -i wlan0 -p udp -m limit --limit 5/second --limit-burst 10 -j ACCEPT
sudo iptables -A INPUT -i wlan0 -p udp -j DROP
sudo iptables -A INPUT -i eth1 -p udp -m limit --limit 5/second --limit-burst 10 -j ACCEPT
sudo iptables -A INPUT -i eth1 -p udp -j DROP

# 丟棄 ping flooding
sudo iptables -A INPUT -i wlan0 -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT
sudo iptables -A INPUT -i wlan0 -p icmp --icmp-type echo-request -j DROP
sudo iptables -A INPUT -i eth1 -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT
sudo iptables -A INPUT -i eth1 -p icmp --icmp-type echo-request -j DROP

# 防止 port scan：封鎖常被掃的 port
sudo iptables -A INPUT -i wlan0 -p tcp --dport 23 -j DROP   # Telnet
sudo iptables -A INPUT -i wlan0 -p tcp --dport 445 -j DROP  # SMB
sudo iptables -A INPUT -i wlan0 -p tcp --dport 135 -j DROP  # RPC

sudo iptables -A INPUT -i eth1 -p tcp --dport 23 -j DROP
sudo iptables -A INPUT -i eth1 -p tcp --dport 445 -j DROP
sudo iptables -A INPUT -i eth1 -p tcp --dport 135 -j DROP


sleep 2
sudo apt install -y iptables-persistent
sudo netfilter-persistent save

