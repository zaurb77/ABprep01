# RUN (XTTS-v2): python .\scripts\render_file.py --model xtts --ref .\audio\ref\ref_01.wav --text .\book_text\book.norm.sent.txt --out .\out\book.wav
# RUN (Donu):    python .\scripts\render_file.py --model donu --ref .\audio\ref\ref_01.wav --text .\book_text\book.norm.sent.txt --out .\out\book.wav

import os, argparse
from TTS.api import TTS

def load_tts(choice: str, base_dir: str):
    if choice == "xtts":
        return TTS("tts_models/multilingual/multi-dataset/xtts_v2", gpu=False)
    elif choice == "donu":
        d = os.path.join(base_dir, "models", "NeuroDonuRU-XTTS-DonuModel")
        return TTS(model_path=d, config_path=os.path.join(d, "config.json"), progress_bar=False)
    raise SystemExit("Unknown --model (use: xtts | donu)")

def main():
    p = argparse.ArgumentParser()
    p.add_argument("--model", required=True, choices=["xtts","donu"])
    p.add_argument("--ref", required=True, help="10–20s clean reference WAV/MP3")
    p.add_argument("--text", required=True, help="normalized text (.norm or .norm.sent)")
    p.add_argument("--out", required=True, help="output WAV path")
    p.add_argument("--lang", default="ru")
    a = p.parse_args()

    base = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    assert os.path.exists(a.ref), f"ref not found: {a.ref}"
    assert os.path.exists(a.text), f"text not found: {a.text}"
    os.makedirs(os.path.dirname(a.out), exist_ok=True)

    with open(a.text, "r", encoding="utf-8") as f:
        txt = f.read().strip()

    tts = load_tts(a.model, base)
    tts.tts_to_file(text=txt, speaker_wav=a.ref, language=a.lang, file_path=a.out)
    print("Done ->", a.out)

if __name__ == "__main__":
    main()
