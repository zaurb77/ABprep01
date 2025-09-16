# scripts/ABprep06-make_listening_sheet.ps1
# Builds .\out\listening_notes.csv for your A/B files.
# Tries to add duration via ffprobe if available; otherwise leaves it blank.

$ErrorActionPreference = "Stop"
$null = New-Item -ItemType Directory -Force -Path .\out | Out-Null
$csv = ".\out\listening_notes.csv"

# Candidate files (add more here if needed)
$targets = @(
  @{ file=".\out\ab_xtts_male.wav";   voice="male";   engine="xtts" },
  @{ file=".\out\ab_donu_male.wav";   voice="male";   engine="donu" },
  @{ file=".\out\ab_xtts_female.wav"; voice="female"; engine="xtts" },
  @{ file=".\out\ab_donu_female.wav"; voice="female"; engine="donu" }
)

# Try ffprobe (PATH or .\tools\ffmpeg\ffprobe.exe)
$ffprobe = "ffprobe"
$ffOk = $true
try { & $ffprobe -version > $null 2>&1 } catch {
  $local = Join-Path (Resolve-Path .) "tools\ffmpeg\ffprobe.exe"
  if (Test-Path $local) { $ffprobe = $local } else { $ffOk = $false }
}
if ($ffOk) {
  try { & $ffprobe -version > $null 2>&1 } catch { $ffOk = $false }
}

$rows = @()
foreach($t in $targets){
  if (Test-Path $t.file) {
    $dur = ""
    if ($ffOk) {
      try {
        $raw = & $ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $t.file 2>$null
        if ($raw) { $dur = [math]::Round([double]$raw,2) }
      } catch { $dur = "" }
    }
    $rows += [pscustomobject]@{
      voice              = $t.voice
      engine             = $t.engine
      file               = $t.file
      duration_sec       = $dur
      score_naturalness  = ""
      score_stress       = ""
      notes              = ""
    }
  }
}

if (-not $rows) { Write-Host "No test files found in .\out. Run the smoke tests first."; exit 1 }

$rows | Export-Csv -NoTypeInformation -Encoding UTF8 $csv
Write-Host "Created $csv"

# Open in Notepad for quick editing
Start-Process notepad $csv
