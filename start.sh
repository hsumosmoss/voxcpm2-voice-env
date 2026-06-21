#!/usr/bin/env bash
# start.sh - 啟動 VoxCPM2 錄音網頁介面 (macOS/Linux)
set -euo pipefail

cd "$(dirname "$0")"

# 檢查是否已安裝
if [ ! -f ".venv/bin/python3" ]; then
  echo "========================================"
  echo "  尚未安裝，請先執行 bash install.sh"
  echo "========================================"
  exit 1
fi

# 建立 voices 目錄
mkdir -p voices

# 關閉舊伺服器
lsof -ti:7860 | xargs kill -9 2>/dev/null || true

echo "正在啟動 VoxCPM2 Voice Cloner..."

# 啟動伺服器
.venv/bin/python3 app.py &
SERVER_PID=$!

# 等待伺服器啟動
echo "等待伺服器啟動中..."
for i in $(seq 1 30); do
  if curl -s http://127.0.0.1:7860 >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

echo "啟動完成！打開瀏覽器: http://127.0.0.1:7860"
open http://127.0.0.1:7860

echo ""
echo "按 Ctrl+C 停止伺服器"
wait $SERVER_PID
