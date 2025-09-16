# scripts/ABprep02b-fix_voicepack.ps1
# Reconvert MP3/WAV refs to mono 22.05k WAV WITHOUT trimming (keeps full length),
# then rebuilds .\audio\ref\voicepack.json and validates.

$ErrorActionPreference = "Stop"
$null = New-Item -ItemType Directory -Force -Path .\audio\ref\male, .\audio\ref\female, .\out | Out-Null

# Use ffmpeg in PATH or at .\tools\ffmpeg\ffmpeg.exe
$ffmpeg = "ffmpeg"
try { & $ffmpeg -version > $null 2>&1 } catch {
  $local = Join-Path (Resolve-Path .) "tools\ffmpeg\ffmpeg.exe"
  if (Test-Path $local) { $ffmpeg = $local }
}
try { & $ffmpeg -version > $null 2>&1 } catch {
  Write-Host "ERROR: ffmpeg not found. Put ffmpeg.exe at .\tools\ffmpeg\ffmpeg.exe or install via winget/choco."
  exit 1
}

# Reconvert every .mp3/.wav under .\audio\ref\ except already-normalized *_norm.wav
$inputs = Get-ChildItem .\audio\ref -Recurse -Include *.mp3, *.wav |
          Where-Object { $_.Name -notlike "*_norm.wav" }
if (-not $inputs) {
  Write-Host "No source MP3/WAV files found (excluding *_norm.wav)."
  exit 1
}

foreach ($f in $inputs) {
  $dst = Join-Path $f.DirectoryName ($f.BaseName + "_norm.wav")
  # IMPORTANT: no silenceremove here; keep full length, just mono+22050 + loudness normalize
  & $ffmpeg -y -hide_banner -loglevel error -i $f.FullName `
    -ac 1 -ar 22050 -af "loudnorm=I=-18:LRA=11:TP=-1.5" `
    $dst
  if ($LASTEXITCODE -ne 0) { throw "ffmpeg failed on $($f.FullName)" }
}

# Rebuild voicepack.json (first normalized male/female; include root ref_01 if present)
$voices = @()
$male = Get-ChildItem .\audio\ref\male\*_norm.wav -ErrorAction SilentlyContinue | Sort-Object Name | Select-Object -First 1
$fem  = Get-ChildItem .\audio\ref\female\*_norm.wav -ErrorAction SilentlyContinue | Sort-Object Name | Select-Object -First 1
$root = Get-ChildItem .\audio\ref\ref_01*_norm.wav -ErrorAction SilentlyContinue | Sort-Object Name | Select-Object -First 1

if ($male) { $voices += @{ name="ru_male_neutral";   ref=(Resolve-Path -Relative $male.FullName); lang="ru"; notes="male neutral, cleaned (no trim)"; } }
if ($fem ) { $voices += @{ name="ru_female_neutral"; ref=(Resolve-Path -Relative $fem.FullName);  lang="ru"; notes="female neutral, cleaned (no trim)"; } }
if ($root) { $voices += @{ name="ru_root_ref01";     ref=(Resolve-Path -Relative $root.FullName); lang="ru"; notes="root ref_01 (no trim)"; } }

if (-not $voices) { Write-Host "No normalized refs found."; exit 1 }

$vp = @{ voices = $voices }
$vp | ConvertTo-Json -Depth 4 | Set-Content -Encoding UTF8 .\audio\ref\voicepack.json
Write-Host "Rebuilt .\audio\ref\voicepack.json"

# Validate (if present)
if (Test-Path .\scripts\wav_validator.py) {
  Write-Host "Running validator..."
  & python .\scripts\wav_validator.py
  if ($LASTEXITCODE -ne 0) {
    Write-Host "Some files still out of range (need 6–20 s). If any file >20 s, trim with -t 15 in ffmpeg."
    exit 1
  }
}

Write-Host "`nDone. Voice pack fixed."
