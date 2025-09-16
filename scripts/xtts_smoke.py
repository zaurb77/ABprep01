# scripts/xtts_smoke.py
import argparse, pathlib
from TTS.api import TTS

ap = argparse.ArgumentParser()
ap.add_argument("--textfile", required=True)
ap.add_argument("--ref", required=True)
ap.add_argument("--out", required=True)
args = ap.parse_args()

text = pathlib.Path(args.textfile).read_text(encoding="utf-8")
pathlib.Path(args.out).parent.mkdir(parents=True, exist_ok=True)

# CPU-only XTTS-v2 (works with TTS==0.22.0, transformers<4.50)
tts = TTS(model_name="tts_models/multilingual/multi-dataset/xtts_v2", gpu=False)
tts.tts_to_file(text=text, speaker_wav=args.ref, language="ru", file_path=args.out)
print(f"ok -> {args.out}")
