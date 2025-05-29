#!/bin/bash

set -e
cd "$(dirname "$0")"

# === [1] Git 確保版本是最新 ===
echo "🔄 檢查 Git 是否為最新版本..."
git fetch origin main
LOCAL_HASH=$(git rev-parse HEAD)
REMOTE_HASH=$(git rev-parse origin/master)

if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
    echo "⚠️ 本地腳本非最新，請先 git pull 同步更新後再執行"
    exit 1
fi

# === [2] 使用者確認 ===
read -p "⚙️ 是否執行網路橋接設定 setup_bridge.sh？(y/N): " confirm1
if [[ "$confirm1" == "y" ]]; then
    bash ./setup_bridge.sh
else
    echo "⏭️ 略過 setup_bridge.sh"
fi

# === [3] 執行防火牆規則 ===
if [ -f ./setiptables2.sh ]; then
    read -p "🛡️ 是否套用防火牆規則 setiptables2.sh？(y/N): " confirm2
    if [[ "$confirm2" == "y" ]]; then
        bash ./setiptables2.sh
    else
        echo "⏭️ 略過 setiptables2.sh"
    fi
else
    echo "⚠️ 找不到 setiptables2.sh"
fi

echo "✅ 所有設定完成！"

