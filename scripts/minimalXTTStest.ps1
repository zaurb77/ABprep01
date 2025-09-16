# Create a small test script that only uses official XTTS-v2
@'
import os
from TTS.api import TTS

BASE = os.path.abspath(os.path.dirname(__file__))
OUT  = os.path.join(BASE, "out"); os.makedirs(OUT, exist_ok=True)
ref_wav = os.path.join(BASE, "audio", "ref", "ref_01.wav")
assert os.path.exists(ref_wav), f"Reference not found: {ref_wav}"

tts = TTS("tts_models/multilingual/multi-dataset/xtts_v2", gpu=False)
tts.tts_to_file(
    text="Короткий тест. Проверяем, что синтез работает.",
    speaker_wav=ref_wav,
    language="ru",
    file_path=os.path.join(OUT, "diag_xtts.wav")
)
print("OK ->", os.path.join(OUT,"diag_xtts.wav"))
'@ | Set-Content -Encoding UTF8 .\scripts\diag_xtts.py

python .\scripts\diag_xtts.py
