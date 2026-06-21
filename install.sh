#!/usr/bin/env bash
# install.sh - VoxCPM2 Voice Cloner 自動安裝腳本 (macOS/Linux)
# 自動偵測 Apple Silicon (MPS) / CPU
#
# 用法：bash install.sh
#
# GPU 偵測邏輯：
#   Apple Silicon (M1/M2/M3/M4) → MPS 加速
#   Intel Mac / Linux → CPU 模式

set -euo pipefail

VENV_NAME='.venv'
VENV_PYTHON="$VENV_NAME/bin/python3"
VENV_PIP="$VENV_NAME/bin/pip"

echo ""
echo "============================================"
echo "  VoxCPM2 Voice Cloner - Auto Installer"
echo "============================================"
echo ""

# --- Step 1: 檢查 uv ---
echo "[1/6] 檢查 uv 套件管理器..."
if ! command -v uv &>/dev/null; then
  echo "  uv 未安裝，正在安裝..."
  pip3 install -U uv
else
  echo "  uv 已安裝: $(which uv)"
fi

# --- Step 2: 建立 Python 3.12 venv ---
echo "[2/6] 建立 Python 3.12 虛擬環境..."
if [ -f "$VENV_PYTHON" ]; then
  echo "  $VENV_NAME 已存在，跳過建立。"
else
  uv venv --python 3.12 "$VENV_NAME"
  echo "  venv 建立完成: $VENV_NAME"
fi

# --- Step 3: 偵測裝置 ---
echo "[3/6] 偵測裝置類型..."
DEVICE="cpu"
if [[ "$(uname)" == "Darwin" ]]; then
  ARCH=$(uname -m)
  if [[ "$ARCH" == "arm64" ]]; then
    echo "  偵測到 Apple Silicon ($ARCH) → 使用 MPS 加速"
    DEVICE="mps"
  else
    echo "  偵測到 Intel Mac → 使用 CPU 模式"
    DEVICE="cpu"
  fi
else
  echo "  非 macOS 系統 → 使用 CPU 模式"
  DEVICE="cpu"
fi

# --- Step 4: 安裝 PyTorch ---
echo "[4/6] 安裝 PyTorch..."
uv pip install --python "$VENV_PYTHON" torch --index-url https://download.pytorch.org/whl/cpu
echo "  PyTorch 安裝完成。"

# --- Step 5: 安裝 voxcpm + sounddevice + resampy ---
echo "[5/6] 安裝 voxcpm + sounddevice + resampy..."
uv pip install --python "$VENV_PYTHON" voxcpm sounddevice resampy
echo "  voxcpm + sounddevice + resampy 安裝完成。"

# --- Step 6: 無需 patch ---
echo "[6/6] 無需 patch（非 XPU 模式）。"

# --- 驗證 ---
echo ""
echo "============================================"
echo "  安裝完成！"
echo "============================================"
echo ""
echo "裝置模式: "
if [[ "$DEVICE" == "mps" ]]; then
  echo "  Apple Silicon MPS（加速）"
else
  echo "  CPU（較慢）"
fi
echo ""
echo "下一步："
echo "  1. 錄製參考音：$VENV_PYTHON record.py"
echo "  2. 生成語音：$VENV_PYTHON clone.py \"你想說的文字\""
echo ""

# 儲存裝置類型
echo "$DEVICE" > .device_type
