#!/bin/bash

if [ "$EUID" -ne 0 ]; then 
  echo "請使用 sudo 執行此腳本"
  exit
fi

echo "--- 正在還原網路演算法為 CUBIC (預設) ---"

# 1. 移除設定檔中的 BBR 相關行
sed -i '/net.core.default_qdisc=fq/d' /etc/sysctl.conf
sed -i '/net.ipv4.tcp_congestion_control=bbr/d' /etc/sysctl.conf

# 2. 強制設定回 cubic
sysctl -w net.ipv4.tcp_congestion_control=cubic
sysctl -w net.core.default_qdisc=pfifo_fast

# 3. 使設定生效
sysctl -p

echo "還原完成！"
sysctl net.ipv4.tcp_congestion_control
