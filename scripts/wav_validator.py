# scripts/wav_validator.py
# Validates reference WAVs for XTTS/Donu: mono, 22.05k/24k, 6–20s

import glob, wave, contextlib, sys, os

paths = glob.glob(r'.\audio\ref\**\*.wav', recursive=True)
if not paths:
    print("No WAV files found under .\\audio\\ref\\")
    sys.exit(1)

bad = []
for p in sorted(paths):
    try:
        with contextlib.closing(wave.open(p, 'rb')) as w:
            sr  = w.getframerate()
            ch  = w.getnchannels()       # <- correct method
            sw  = w.getsampwidth()
            dur = w.getnframes() / float(sr)
    except Exception as e:
        print(f"{p} -> ERROR: {e}")
        bad.append(p)
        continue

    ok_len = 6.0 <= dur <= 20.0
    ok_ch  = (ch == 1)
    ok_sr  = (sr in (22050, 24000))

    status = "OK" if (ok_len and ok_ch and ok_sr) else "FIX"
    detail = []
    if not ok_len: detail.append(f"length={dur:.1f}s (need 6–20s)")
    if not ok_ch:  detail.append(f"channels={ch} (need mono)")
    if not ok_sr:  detail.append(f"rate={sr} (need 22050 or 24000)")
    details = "; ".join(detail) if detail else f"{dur:.1f}s, {sr} Hz, {ch} ch, {sw*8}-bit"

    print(f"{os.path.relpath(p)} -> {status}: {details}")
    if status == "FIX":
        bad.append(p)

# Exit 0 if all good, 1 if any need fixing (so CI/scripts can gate)
sys.exit(0 if not bad else 1)
