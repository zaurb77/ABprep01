from pathlib import Path
from TTS.api import TTS

# Repo root (…/ABprep01), not the scripts folder
ROOT = Path(__file__).resolve().parent.parent
OUT  = ROOT / "out"
OUT.mkdir(parents=True, exist_ok=True)

# Reference clip inside the repo
REF = ROOT / "audio" / "ref" / "ref_01.wav"
assert REF.exists(), f"Reference not found: {REF}"

# Official XTTS-v2 by name (CPU)
tts = TTS("tts_models/multilingual/multi-dataset/xtts_v2", gpu=False)

tts.tts_to_file(
    text="Короткий тест. Проверяем, что синтез работает.",
    speaker_wav=str(REF),
    language="ru",
    file_path=str(OUT / "diag_xtts.wav"),
)

print("OK ->", OUT / "diag_xtts.wav")
