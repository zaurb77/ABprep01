# RUN: python .\scripts\test_tts.py
import os
from TTS.api import TTS

BASE = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OUT  = os.path.join(BASE, "out")
os.makedirs(OUT, exist_ok=True)

# official XTTS-v2 (by name; CPU)
tts_off = TTS("tts_models/multilingual/multi-dataset/xtts_v2", gpu=False)

# Donu (pass the FOLDER, not ...\model.pth)
donu_dir = os.path.join(BASE, "models", "NeuroDonuRU-XTTS-DonuModel")
tts_donu = TTS(model_path=donu_dir,
               config_path=os.path.join(donu_dir, "config.json"),
               progress_bar=False)

ref_wav = os.path.join(BASE, "audio", "ref", "ref_01.wav")  # put your 10–20s clean clip here
assert os.path.exists(ref_wav), f"Reference not found: {ref_wav}"

text = "Это короткий тест синтеза речи. Мы проверяем естественность и постановку ударений."

tts_off.tts_to_file(text=text, speaker_wav=ref_wav, language="ru",
                    file_path=os.path.join(OUT, "smoketest_official_xtts.wav"))

tts_donu.tts_to_file(text=text, speaker_wav=ref_wav, language="ru",
                     file_path=os.path.join(OUT, "smoketest_donu_xtts.wav"))

print("Done ->", OUT)
