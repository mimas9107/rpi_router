# Raspberry Pi 簡易路由器設定

本專案旨在將 Raspberry Pi 快速設定為一個簡易的網路路由器，特別適用於將手機 USB 網路或外部 WiFi 連線，分享給連接到 Pi 的有線網路孔 (eth0) 的下游設備 (例如另一台家用 WiFi AP)。

---

## ✨ 專案結構 (新版)

為了讓設定更清晰、更容易管理，專案已重構為以「模式」為基礎的目錄結構。**建議使用以下新結構中的腳本**。

```
/
├── router_mode_usb/        # ✅【推薦】模式一：透過手機 USB 分享網路
│   ├── install.sh          #    一鍵安裝腳本
│   └── uninstall.sh        #    一鍵解除安裝腳本
│
└── router_mode_wifi/       # ✅【推薦】模式二：透過 WiFi 分享網路
    ├── install.sh          #    一鍵安裝腳本
    └── uninstall.sh        #    一鍵解除安裝腳本
```

舊有的 `dhcp_mode`, `bridge_mode` 等檔案和目錄已作為歷史備份保留，不建議再使用。

---

## 🚀 快速開始

### 前置需求
1. 一台 Raspberry Pi 4。
2. 已安裝 Raspberry Pi OS (或其他基於 Debian 的系統)。
3. Pi 已具備網路連線能力（用於下載所需軟體）。

### 模式一：透過手機 USB 分享網路 (`router_mode_usb`)

這是最主要的應用場景。將手機透過 USB 線連接到 Pi，並開啟「USB 網路共用」功能。Pi 會將此網路分享給 `eth0` 網孔。

**安裝:**
```bash
# 1. 進入 usb 模式目錄
cd router_mode_usb

# 2. 執行安裝腳本 (需要 root 權限)
sudo ./install.sh
```
腳本會自動安裝 `dnsmasq`、設定防火牆、啟用 IP 轉發，並設定 Pi 的有線網孔 (`eth0`) IP 為 `192.168.88.1`。連接到 `eth0` 的下游設備將會自動獲取 `192.168.88.x` 的 IP 位址。

**解除安裝:**
```bash
# 1. 進入 usb 模式目錄
cd router_mode_usb

# 2. 執行解除安裝腳本
sudo ./uninstall.sh
```
此腳本會移除 `dnsmasq`、清除防火牆規則並還原網路設定。

---

### 模式二：透過 WiFi 分享網路 (`router_mode_wifi`)

此模式適用於 Pi 先連接到一個外部的 WiFi 網路 (例如：手機開的 WiFi 熱點)，然後再透過 `eth0` 有線網孔將網路分享出去。

**安裝:**
在執行腳本前，請先確保您的 Raspberry Pi 已經成功連上外部的 WiFi (`wlan0`)。
```bash
# 1. 進入 wifi 模式目錄
cd router_mode_wifi

# 2. 執行安裝腳本
sudo ./install.sh
```

**解除安裝:**
```bash
# 1. 進入 wifi 模式目錄
cd router_mode_wifi

# 2. 執行解除安裝腳本
sudo ./uninstall.sh
```

---
## 🛠️ 如何驗證

安裝完成後，您可以透過以下指令檢查設定是否成功：

*   **檢查 `eth0` 的 IP 位址:**
    ```bash
    ip addr show eth0
    ```
    您應該會看到 `inet 192.168.88.1/24` 的設定。

*   **檢查 `dnsmasq` 服務狀態:**
    ```bash
    systemctl status dnsmasq
    ```
    您應該會看到 `active (running)` 的綠色狀態。

*   **檢查 `iptables` NAT 規則:**
    ```bash
sh
    sudo iptables -t nat -L POSTROUTING -v
    ```
    您應該會看到一條 `MASQUERADE` 規則，其 `out-interface` 為 `usb0` 或 `wlan0` (取決於您安裝的模式)。
