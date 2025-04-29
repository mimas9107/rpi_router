## 測試 RPi4作為網關～
### eth0: RPi4 LAN孔 
### eth1: 測試用手機 usb分享網路給 RPi4
### wlan0: 測試用手機 wifi熱點分享網路給 RPi4

### RPi4 LAN孔 接網路線到 wifi分享器的 WAN孔。
### wifi分享器本身 WAN連線設定為 dhcp ip模式交給 RPi4派發 ip，並設定分享器的區域網路ip分配，與無線網路ssid、密碼。

---
1. sudo apt update && sudo apt upgrade -y

2. sudo apt install dnsmasq

3. 依照要建立的網路環境編輯設定檔 /etc/dnsmasq.conf
```bash
interface=eth0
dhcp-range=<要分配的ip range起始> <要分配的ip range結尾>, <netmask>, 24h
```
4. /etc/sysctl.conf 增加設定：
```bash
net.ipv4.ip_forward=1
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
```
存檔後執行： 將設定載入
```bash
$ sudo sysctl -p
```

5. 執行專案中的設定腳本： 
```bash
dhcp_mode/
    setup_bridge.sh
    setiptables2.sh
```
6. RPi4 重開機、分享器也重開機

 
