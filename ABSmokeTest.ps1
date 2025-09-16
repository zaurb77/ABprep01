cd D:\Projects\AudioBooks\ABprep01
.\.venv\Scripts\Activate.ps1
Test-Path .\audio\ref\ref_01.wav   # should print True

python .\scripts\test_tts.py
