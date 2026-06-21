> 🙏 感謝 **三師爸**，本專案來源來自 [三師爸](https://github.com/mathruffian-dot/voxcpm2-voice-cloner)。原始專案提供 VoxCPM2 的自動安裝、錄音與克隆工具鏈。

# VoxCPM2 Voice Cloner

用 VoxCPM2 克隆你的聲音，生成任意語音。全自動安裝，自動偵測 GPU / MPS。

**錄音走 UI，其他全部透過 AI Agent 自然語言操作。**

## 特色

- **跨平台**：Windows（NVIDIA CUDA / Intel Arc XPU / CPU）+ macOS（Apple Silicon MPS / CPU）
- **自動偵測裝置**：CUDA / XPU / MPS / CPU 自動切換
- **Ultimate Cloning**：同時使用參考音 + 逐字稿，連語氣節奏都一起複製
- **網頁錄音**：`app.py` 提供簡潔錄音介面（取名 → 看稿 → 錄音 → 儲存）
- **自然語言操作**：錄完後，直接對 AI Agent 說「用王老師的聲音說一段話」，Agent 自動呼叫工具
- **Apache-2.0 授權**：VoxCPM2 模型可商用

## 系統需求

- **Windows** 10/11 或 **macOS** (Apple Silicon / Intel)
- Python 3.10–3.12（安裝腳本會用 uv 自動建立 3.12 環境）
- 顯卡（擇一）：
  - NVIDIA GPU（CUDA 12+，約 8GB VRAM）
  - Intel Arc GPU（XPU，約 8GB VRAM，需自動 patch）
  - Apple Silicon（MPS 加速，約 8GB 統一記憶體）
  - 無獨顯也可用 CPU（較慢，RTF 約 8x）
- 約 5GB 硬碟空間（模型權重）
- 麥克風

## 快速開始

### 🪟 Windows

#### 1. 安裝
雙擊 `install.bat`（或 `install.ps1`）。自動完成所有設定。

#### 2. 錄音
雙擊 `start.bat` → 瀏覽器打開 → 取名 → 對著麥克風念稿 → 儲存。

#### 3. 使用（透過 AI Agent）
直接對 AI Agent 說：
```
用王老師的聲音說「同學們早安，今天我們來上數學課」
```

Agent 會自動找到對應聲音、生成語音、回傳音檔。

### 🍎 macOS

#### 1. 安裝
```bash
bash install.sh
```

#### 2. 錄音
```bash
bash start.sh
# 瀏覽器自動開啟 http://127.0.0.1:7860
```

或命令列錄音：
```bash
.venv/bin/python3 record.py --voice 我的聲音
```

#### 3. 生成克隆語音
```bash
.venv/bin/python3 clone.py "你好，這是我的克隆聲音。" --voice 我的聲音
```

> 💡 本專案設計為 **AI Agent 工具包**，人類只做錄音，其他交給 Agent。

### 錄製參考音

有兩種方式：

**方式 A：網頁介面（推薦）**
- Windows: `.\.venv\Scripts\python.exe webui_record.py`
- macOS: `.venv/bin/python3 webui_record.py`

瀏覽器自動開啟，有錄音按鈕、逐字稿顯示，錄完自動存檔。

**方式 B：命令列**
```bash
python record.py --voice 我的聲音
```

螢幕會顯示一段文字，對著麥克風自然地朗讀，念完按 Enter 停止。

### 生成克隆語音

```bash
python clone.py "你好，這是我的克隆聲音。" --voice 我的聲音
```

或從文字檔生成：
```bash
python clone.py --file my_script.txt
```

輸出檔案預設在 `output/cloned_voice.wav`。

## 目錄結構

```
voxcpm2-voice-cloner/
├── app.py                    # 錄音 UI（唯一介面）
├── clone.py                  # Agent 工具：用聲音生成語音
├── dialogue.py               # Agent 工具：多聲音對話
├── record.py                 # 命令列錄音（備案）
├── start.bat / start.sh      # 啟動錄音 UI
├── install.bat               # Windows 安裝（雙擊）
├── install.ps1               # Windows 安裝（自動偵測 GPU）
├── install.sh                # macOS/Linux 安裝（自動偵測 MPS/CPU）
├── AGENTS.md                 # Agent 使用指南
├── texts/sample_text.txt     # 錄音時朗讀的文字
├── voices/                   # 已錄製的聲音（本地，不進版控）
├── patches/                  # Intel Arc XPU 支援
└── output/                   # 生成的語音
```

## 裝置支援對照

| 裝置 | 模式 | PyTorch | 需要 patch | 效能（參考） |
|------|------|---------|-----------|-------------|
| NVIDIA (CUDA 12+) | cuda | cu128 wheel | 不需要 | RTF ~0.3（RTX 4090） |
| Intel Arc (XPU) | xpu | xpu wheel | 需要（自動） | RTF ~2.0（Arc 140T） |
| Apple Silicon (MPS) | mps | cpu wheel | 不需要 | RTF ~1.5（M4） |
| 無獨顯 | cpu | cpu wheel | 不需要 | RTF ~8.0 |

> RTF = 生成 N 秒語音所需的時間倍率，越低越快。

## Intel Arc (XPU) 注意事項

VoxCPM2 官方目前只支援 NVIDIA CUDA。Intel Arc 的 XPU 支援透過 patch 實現：

- `install.ps1` 會自動套用 patch
- 若 `pip install -U voxcpm` 更新了套件，patch 會被覆蓋
- 執行 `.\patches\repatch_xpu.ps1` 即可恢復

## macOS 注意事項

- Apple Silicon（M1/M2/M3/M4）使用 MPS 加速，效能約為 RTF ~1.5
- Intel Mac 僅支援 CPU 模式（較慢）
- `sounddevice` 需額外安裝 PortAudio：`brew install portaudio`
- 麥克風權限請在「系統設定 → 隱私權與安全性 → 麥克風」中啟用終端機

## 授權

- VoxCPM2 模型與程式碼：[Apache-2.0](https://github.com/OpenBMB/VoxCPM/blob/main/LICENSE)（可商用）
- 本專案腳本：MIT
