# scripts/ABprep02-make_voicepack.ps1
# Converts MP3/WAV refs under .\audio\ref\**\ to mono 22.05k WAV (_norm.wav),
# then builds .\audio\ref\voicepack.json. Also runs the validator if present.

$ErrorActionPreference = "Stop"

# 0) Ensure expected folders exist
$null = New-Item -ItemType Directory -Force -Path .\audio\ref\male, .\audio\ref\female, .\out | Out-Null

# 1) If your files are currently in .\ref\... (not .\audio\ref\...), move them once:
if (Test-Path .\ref) {
  robocopy .\ref .\audio\ref /E | Out-Null
}

# 2) Find ffmpeg
$ffmpeg = "ffmpeg"
try { & $ffmpeg -version >$null 2>&1 } catch {
  $local = Join-Path (Resolve-Path .) "tools\ffmpeg\ffmpeg.exe"
  if (Test-Path $local) { $ffmpeg = $local }
}
$ffOk = $true
try { & $ffmpeg -version >$null 2>&1 } catch { $ffOk = $false }
if (-not $ffOk) {
  Write-Host "ERROR: ffmpeg not found. Install if you want (internet needed):"
  Write-Host "  winget install --id=Gyan.FFmpeg -e   OR   choco install ffmpeg -y"
  Write-Host "Or place ffmpeg.exe at .\tools\ffmpeg\ffmpeg.exe"
  exit 1
}

# 3) Convert and normalize every *.mp3 / *.wav under .\audio\ref\
$inputs = Get-ChildItem .\audio\ref -Recurse -Include *.mp3, *.wav
if (-not $inputs) {
  Write-Host "No ref files found under .\audio\ref\. Put MP3/WAVs into .\audio\ref\male and \female."
  exit 1
}
foreach($f in $inputs){
  $dst = Join-Path $f.DirectoryName ($f.BaseName + "_norm.wav")
  & $ffmpeg -y -hide_banner -loglevel error -i $f.FullName `
    -ac 1 -ar 22050 `
    -af "silenceremove=start_periods=1:start_silence=0.35:start_threshold=-35dB:stop_periods=1:stop_silence=0.35:stop_threshold=-35dB,loudnorm=I=-18:LRA=11:TP=-1.5" `
    $dst
  if ($LASTEXITCODE -ne 0) { throw "ffmpeg failed on $($f.Name)" }
}

# 4) Build voicepack.json (pick first normalized male/female; also include root ref_01)
$voices = @()
$male = Get-ChildItem .\audio\ref\male\*_norm.wav -ErrorAction SilentlyContinue | Sort-Object Name | Select-Object -First 1
$fem  = Get-ChildItem .\audio\ref\female\*_norm.wav -ErrorAction SilentlyContinue | Sort-Object Name | Select-Object -First 1
$root = Get-ChildItem .\audio\ref\ref_01*.wav -ErrorAction SilentlyContinue | Sort-Object Name | Select-Object -First 1

if($male){ $voices += @{ name="ru_male_neutral";   ref=(Resolve-Path -Relative $male.FullName); lang="ru"; notes="male neutral, cleaned"; } }
if($fem ){ $voices += @{ name="ru_female_neutral"; ref=(Resolve-Path -Relative $fem.FullName);  lang="ru"; notes="female neutral, cleaned"; } }
if($root){ $voices += @{ name="ru_root_ref01";     ref=(Resolve-Path -Relative $root.FullName); lang="ru"; notes="root ref_01 (optional)"; } }

if(-not $voices){
  Write-Host "No normalized refs found. Make sure you placed files under .\audio\ref\male and \female."
  exit 1
}

$vp = @{ voices = $voices }
$vp | ConvertTo-Json -Depth 4 | Set-Content -Encoding UTF8 .\audio\ref\voicepack.json
Write-Host "Created .\audio\ref\voicepack.json"

# 5) Validate if validator exists
if (Test-Path .\scripts\wav_validator.py) {
  Write-Host "Running validator..."
  & python .\scripts\wav_validator.py
  if ($LASTEXITCODE -ne 0) {
    Write-Host "Some files need fixing (length/mono/rate). See lines above."
    exit 1
  }
}

Write-Host "`nAll set. Voice pack ready:"
Get-Content .\audio\ref\voicepack.json
