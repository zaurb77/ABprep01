# scripts/ABprep03-xtts_smoke.ps1
# Runs the XTTS smoke test with clear checks and messages.

$ErrorActionPreference = "Stop"

# 1) Read female ref from voicepack.json
if (-not (Test-Path .\audio\ref\voicepack.json)) {
  Write-Host "voicepack.json not found at .\audio\ref\voicepack.json"; exit 1
}
$vp = Get-Content .\audio\ref\voicepack.json | ConvertFrom-Json

$femaleRef = ($vp.voices | Where-Object { $_.name -eq 'ru_female_neutral' } | Select-Object -First 1).ref
if (-not $femaleRef) {
  # fallback to first female *_norm.wav
  $femaleRef = (Get-ChildItem .\audio\ref\female\*_norm.wav | Sort-Object Name | Select-Object -First 1).FullName
}
if (-not $femaleRef) {
  # fallback to ref_01_norm.wav
  $femaleRef = (Get-ChildItem .\audio\ref\ref_01*_norm.wav -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
}
if (-not $femaleRef) { Write-Host "No female reference WAV found."; exit 1 }

# Resolve to absolute path (avoids any relative path issues)
$femaleAbs = (Resolve-Path $femaleRef).Path
Write-Host "Using female ref: $femaleAbs"

# 2) Ensure text exists (create if missing)
if (-not (Test-Path .\book_text\ab_smoke.txt)) {
@'
Привет! Это короткий тест.

Сегодня мы проверяем ударения и паузы.
Всё должно звучать естественно.
'@ | Set-Content -Encoding UTF8 .\book_text\ab_smoke.txt
}

# 3) Run the python script (unbuffered for immediate prints)
$out = ".\out\ab_xtts_female.wav"
Write-Host "Generating: $out"
python -u .\scripts\xtts_smoke.py --textfile .\book_text\ab_smoke.txt --ref "$femaleAbs" --out "$out"

if ($LASTEXITCODE -ne 0) {
  Write-Host "`nXTTS smoke FAILED. Quick fixes:"
  Write-Host "  - Activate venv: .\.venv\Scripts\Activate.ps1"
  Write-Host "  - Install TTS:   pip install TTS==0.22.0"
  Write-Host "  - Pin transfs:   pip install 'transformers<4.50' --upgrade"
  exit 1
}

# 4) Confirm output
if (Test-Path $out) {
  Write-Host "OK -> $out"
  Get-Item $out | Format-List FullName, Length
} else {
  Write-Host "Done, but output file not found. Check errors above."
  exit 1
}
