# RUN: .\ABprep01-download_models.ps1
# Assumes venv is active and TTS + huggingface-hub are installed

$XTTS = "D:\Projects\AudioBooks\ABprep01\models\XTTS-v2"

# Download once (idempotent)
python -c "from huggingface_hub import snapshot_download; snapshot_download('coqui/XTTS-v2', local_dir=r'$XTTS', local_dir_use_symlinks=False); print('XTTS-v2 downloaded')"

# Load test from local paths (CPU)
python -c "from TTS.api import TTS; TTS(model_path=r'$XTTS\model.pth', config_path=r'$XTTS\config.json', progress_bar=False); print('XTTS-v2 local load OK')"

# RUN: .\ABprep01-download_xtts_v2.ps1
# Assumes venv is active and TTS is installed

# This pulls coqui/XTTS-v2 into the HF cache and verifies it can load.
python -c "from TTS.api import TTS; t=TTS('tts_models/multilingual/multi-dataset/xtts_v2', gpu=False); print('XTTS-v2 fetch+import OK')"
