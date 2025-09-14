# RUN: .\scripts\ABprep01-download_xtts_v2.ps1
# Requires: venv active and TTS installed
python -c "from TTS.api import TTS; TTS('tts_models/multilingual/multi-dataset/xtts_v2', gpu=False); print('XTTS-v2 fetch+import OK')"
