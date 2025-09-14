# ABprep01 — CPU-only Russian Audiobook TTS (XTTS-v2 / Donu)

**Goal:** Generate *natural* Russian narration on **Windows / CPU only** using:
- **Official Coqui XTTS-v2** (baseline; loaded by model name, cached automatically).
- **Local Donu RU fine-tune** (optional; load from a folder with `config.json` + `model.pth`).

This repo is designed to be **simple, reproducible, and portable** across PCs.

---

## 🔧 Prerequisites

- **Windows 10/11**
- **Python 3.10**
- **Microsoft Visual C++ Build Tools 2022** (Desktop C++ workload)  
  *(needed to build a small TTS extension on Windows)*
- **FFmpeg** on PATH (for MP3/video steps)

---

## 🚀 Quickstart (first run)

> All commands below are PowerShell commands executed **in the repo root**.

1) **Create & activate a virtual environment**
```powershell
py -3.10 -m venv .\.venv
.\.venv\Scripts\Activate.ps1
```

2) **Install dependencies**
```powershell
pip install --upgrade pip
pip install -r .\requirements.txt
```

3) **Fetch & cache the official XTTS-v2 model**
```powershell
python -c "from TTS.api import TTS; TTS('tts_models/multilingual/multi-dataset/xtts_v2', gpu=False); print('XTTS-v2 OK')"
```

4) **Add a clean 10–20s narrator reference clip**
```
.\audio\ref\ref_01.wav
```
> Pick **solo speech** (no music/FX), good quality. WAV or MP3 is fine.

5) **Smoke test (A/B: XTTS-v2 vs Donu)**
```powershell
python .\scripts\test_tts.py
```
Outputs:
```
.\out\smoketest_official_xtts.wav
.\out\smoketest_donu_xtts.wav
```

---

## 🗣️ Render a whole file to one WAV

1) Prepare your text:
- Raw book → `.\book_text\book.txt`
- Normalize / split (one sentence per line) → `.\book_text\book.norm.sent.txt`  
  *(Keep **blank lines** between paragraphs to get natural pauses.)*

2) Render (choose the model):

**XTTS-v2 baseline**
```powershell
python .\scripts\render_file.py --model xtts --ref .\audio\ref\ref_01.wav --text .\book_text\book.norm.sent.txt --out .\out\book.wav
```

**Donu fine-tune (if placed at .\models\NeuroDonuRU-XTTS-DonuModel\)**
```powershell
python .\scripts\render_file.py --model donu --ref .\audio\ref\ref_01.wav --text .\book_text\book.norm.sent.txt --out .\out\book.wav
```

---

## 🎚️ Mastering & YouTube

**Normalize loudness** to ~ **−16 LUFS** and encode MP3:
```powershell
ffmpeg -y -i .\out\book.wav -af "loudnorm=I=-16:TP=-1.5:LRA=11" .\out\book_loud.wav
ffmpeg -y -i .\out\book_loud.wav -codec:a libmp3lame -q:a 2 .\out\book.mp3
```

**Make a simple video** (static image + audio):
```powershell
# Place a 1920x1080 cover at .\cover.png
ffmpeg -y -loop 1 -i .\cover.png -i .\out\book.mp3 -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p -shortest .\out\book.mp4
```

---

## 📁 Repo Structure

```
ABprep01/
  .venv/                         (ignored)
  audio/
    ref/
      ref_01.wav                 (your 10–20s clean reference clip)
  book_text/
    book.txt
    book.norm.txt
    book.norm.sent.txt           (1 sentence per line; blank lines = paragraph pause)
  models/
    NeuroDonuRU-XTTS-DonuModel/  (optional local model; not pushed to git)
  out/                           (generated audio/video)
  scripts/
    ABprep01-install_cpu.ps1     (install CPU-only deps)
    ABprep01-download_xtts_v2.ps1(verify XTTS-v2 by name; cached)
    test_tts.py                  (A/B smoke test)
    render_file.py               (render whole file → one WAV)
  requirements.txt
  .gitignore
  README.md
```

---

## 🧪 Troubleshooting

- **`ImportError: from TTS.api` in VS Code**  
  Ensure the interpreter is the venv:  
  *Ctrl+Shift+P → “Python: Select Interpreter” →* pick `.\.venv\Scripts\python.exe`, then **Reload Window**.

- **`MSVC 14+ required` during `pip install TTS`**  
  Install **Visual Studio 2022 Build Tools** with the *Desktop development with C++* workload, then retry.

- **`AttributeError: GPT2InferenceModel ... generate`**  
  Pin Transformers to `< 4.50` (already pinned in `requirements.txt`).

- **`... model.pth/model.pth` path error**  
  Don’t pass file paths as folders. Load XTTS-v2 **by name**; load Donu by **folder** (the script already does this).

---

## 🔁 Reproducible installs on any PC

```powershell
git clone https://github.com/<you>/ABprep01.git
cd ABprep01
py -3.10 -m venv .\.venv
.\.venv\Scripts\Activate.ps1
pip install --upgrade pip
pip install -r .\requirements.txt
python -c "from TTS.api import TTS; TTS('tts_models/multilingual/multi-dataset/xtts_v2', gpu=False); print('XTTS-v2 OK')"
```

Place your reference clip and normalized text as shown above, then run `render_file.py`.

---

## ✅ Notes
- XTTS-v2 supports Russian and voice-cloning from a short reference.
- Donu is optional; place it under `.\models\NeuroDonuRU-XTTS-DonuModel\` if you want to A/B.
- Keep your repo light: models, large audio, and the venv are **ignored** via `.gitignore`.
