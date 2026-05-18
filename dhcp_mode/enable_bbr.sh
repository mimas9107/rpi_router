#!/bin/bash

# 檢查是否具備 root 權限
if [ "$EUID" -ne 0 ]; then 
  echo "請使用 sudo 執行此腳本"
  exit
fi

echo "--- TCP BBR 啟動檢查作業 ---"

# 1. 檢查核心版本 (BBR 需要 4.9+)
KERNEL_MAJOR=$(uname -r | cut -d. -f1)
KERNEL_MINOR=$(uname -r | cut -d. -f2)

if [ "$KERNEL_MAJOR" -lt 4 ] || ([ "$KERNEL_MAJOR" -eq 4 ] && [ "$KERNEL_MINOR" -lt 9 ]); then
    echo "錯誤: 核心版本過舊 ($(uname -r))，不支援 BBR。"
    exit 1
fi

# 2. 檢查設定檔是否已經設定過，避免重複寫入
BBR_SET=$(grep "net.ipv4.tcp_congestion_control=bbr" /etc/sysctl.conf)

if [ -z "$BBR_SET" ]; then
    echo "正在將 BBR 設定寫入 /etc/sysctl.conf..."
    # 備份原始設定檔
    cp /etc/sysctl.conf /etc/sysctl.conf.bak.$(date +%Y%m%d%H%M)
    
    # 寫入 BBR 必要參數
    echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
    echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
    
    # 使設定生效
    sysctl -p
    echo "BBR 已成功寫入並啟動！"
else
    echo "檢查完成：BBR 設定已存在，不需重複操作。"
    # 強制再次生效確保萬無一西
    sysctl -p > /dev/null
fi

# 3. 最終驗證
CURRENT_ALGO=$(sysctl net.ipv4.tcp_congestion_control | awk '{print $3}')
if [ "$CURRENT_ALGO" == "bbr" ]; then
    echo "狀態確認: [成功] 目前 TCP 演算法已切換為: $CURRENT_ALGO"
else
    echo "狀態確認: [失敗] 目前 TCP 演算法仍為: $CURRENT_ALGO"
fi
