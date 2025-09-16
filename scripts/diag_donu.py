from pathlib import Path
from TTS.api import TTS

# Repo root
ROOT = Path(__file__).resolve().parent.parent
OUT  = ROOT / "out"
OUT.mkdir(parents=True, exist_ok=True)

# Reference clip inside the repo
REF = ROOT / "audio" / "ref" / "ref_01.wav"
assert REF.exists(), f"Reference not found: {REF}"

# Local Donu model folder (must contain config.json and model.pth)
DONU   = ROOT / "models" / "NeuroDonuRU-XTTS-DonuModel"
CONFIG = DONU / "config.json"
assert DONU.exists() and CONFIG.exists(), f"Donu model folder or config missing: {DONU}"

# Load Donu by FOLDER (not by .../model.pth file path)
tts = TTS(model_path=str(DONU), config_path=str(CONFIG), progress_bar=False)

tts.tts_to_file(
    text="Короткий тест модели Donu на русском языке.",
    speaker_wav=str(REF),
    language="ru",
    file_path=str(OUT / "diag_donu.wav"),
)

print("OK ->", OUT / "diag_donu.wav")
