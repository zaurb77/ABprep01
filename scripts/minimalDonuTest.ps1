# Make sure the Donu folder exists in this clone (optional step)
Test-Path .\models\NeuroDonuRU-XTTS-DonuModel\model.pth

# Create a Donu-only test script
@'
import os
from TTS.api import TTS

BASE = os.path.abspath(os.path.dirname(__file__))
OUT  = os.path.join(BASE, "out"); os.makedirs(OUT, exist_ok=True)
ref_wav = os.path.join(BASE, "audio", "ref", "ref_01.wav")
assert os.path.exists(ref_wav), f"Reference not found: {ref_wav}"

donu_dir = os.path.join(BASE, "models", "NeuroDonuRU-XTTS-DonuModel")
tts = TTS(model_path=donu_dir, config_path=os.path.join(donu_dir, "config.json"), progress_bar=False)
tts.tts_to_file(
    text="Короткий тест модели Donu на русском языке.",
    speaker_wav=ref_wav,
    language="ru",
    file_path=os.path.join(OUT, "diag_donu.wav")
)
print("OK ->", os.path.join(OUT,"diag_donu.wav"))
'@ | Set-Content -Encoding UTF8 .\scripts\diag_donu.py

python .\scripts\diag_donu.py
