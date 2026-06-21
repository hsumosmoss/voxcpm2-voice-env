import os, sys, time
import soundfile as sf

REPO_DIR = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(REPO_DIR, "assets", "narration")
os.makedirs(OUT, exist_ok=True)

VOICE = "許耀文"
SAMPLE_RATE = 16000

SCRIPT = [
    (1, "你知道嗎？外面餐廳的紅燒牛肉麵永遠比家裡好吃。不是師傅偷加了什麼，而是梅納反應在幫他。"),
    (2, "就像烤肉時表面那層金黃焦香的脆皮。牛肉麵的靈魂，來自牛肉表面在高溫下產生的梅納反應。"),
    (3, "當牛肉加熱到攝氏一百四十度以上，肉中的胺基酸和糖分開始劇烈反應，生成數百種香氣化合物。這就是梅納反應。"),
    (4, "同一鍋裡還發生焦糖化。糖加熱到一百六十度，產生更深層的焦甜味與紅褐色澤。"),
    (5, "祕密一：牛肉下鍋前，先用大火把表面煎到焦黃。梅納反應需要高溫，燉煮的低溫來不及。"),
    (6, "祕密二：加一小匙番茄醬。番茄醬提供天然還原糖和酸度，能加速梅納反應，讓湯底更深層。"),
    (7, "祕密三：小火慢燉至少一個半小時。時間越長，胺基酸和糖的反應越充分，湯頭越濃郁。"),
    (8, "一碗好吃的紅燒牛肉麵，從梅納反應開始。下次煮麵，記得先煎再燉。"),
]

def detect_device():
    for marker in ['.device_type', '.gpu_type']:
        path = os.path.join(REPO_DIR, marker)
        if os.path.exists(path):
            with open(path, 'r', encoding='utf-8') as f:
                return f.read().strip()
    import torch
    if torch.cuda.is_available():
        return 'cuda'
    if hasattr(torch, 'xpu') and torch.xpu.is_available():
        return 'xpu'
    if hasattr(torch.backends, 'mps') and torch.backends.mps.is_available():
        return 'mps'
    return 'cpu'

def main():
    device = detect_device()
    voice_dir = os.path.join(REPO_DIR, "voices", VOICE)
    reference = os.path.join(voice_dir, "ref_voice.wav")
    text_file = os.path.join(voice_dir, "prompt.txt")

    if not os.path.exists(reference):
        print(f"錯誤：找不到參考音檔 {reference}")
        sys.exit(1)
    if not os.path.exists(text_file):
        print(f"錯誤：找不到逐字稿 {text_file}")
        sys.exit(1)

    with open(text_file, 'r', encoding='utf-8') as f:
        prompt_text = f.read().strip()

    from voxcpm import VoxCPM

    print(f"聲音: {VOICE}")
    print(f"裝置: {device}")
    print("載入 VoxCPM2 模型...")
    t0 = time.time()
    model = VoxCPM.from_pretrained(
        'openbmb/VoxCPM2',
        load_denoiser=False,
        device=device,
        optimize=False,
    )
    print(f"模型載入完成，耗時 {time.time()-t0:.1f}s")

    for i, text in SCRIPT:
        print(f"生成第 {i} 頁...（{len(text)} 字）")
        t1 = time.time()
        wav = model.generate(
            text=text,
            prompt_wav_path=reference,
            prompt_text=prompt_text,
            reference_wav_path=reference,
            cfg_value=2.0,
            inference_timesteps=10,
        )
        elapsed = time.time() - t1
        duration = len(wav) / model.tts_model.sample_rate
        print(f"  完成: {duration:.1f}s（RTF={elapsed/duration:.1f}）")

        out_path = os.path.join(OUT, f"page-{i:02d}.wav")
        sf.write(out_path, wav, model.tts_model.sample_rate)
        print(f"  存檔: {out_path}")

    print("所有旁白生成完成！")

if __name__ == "__main__":
    main()
