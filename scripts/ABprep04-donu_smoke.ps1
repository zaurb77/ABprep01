# scripts/ABprep04b-donu_smoke_fix.ps1
# Forces Donu engine (tries common flags), captures hardcoded diag output, renames to our targets.

$ErrorActionPreference = "Stop"

# --- refs from voicepack ---
if (-not (Test-Path .\audio\ref\voicepack.json)) { Write-Host "Missing .\audio\ref\voicepack.json"; exit 1 }
$vp = Get-Content .\audio\ref\voicepack.json | ConvertFrom-Json

$maleRef = ($vp.voices | Where-Object { $_.name -eq 'ru_male_neutral' } | Select-Object -First 1).ref
if (-not $maleRef) { $maleRef = (Get-ChildItem .\audio\ref\male\*_norm.wav | Sort-Object Name | Select-Object -First 1).FullName }
$femRef  = ($vp.voices | Where-Object { $_.name -eq 'ru_female_neutral' } | Select-Object -First 1).ref
if (-not $femRef ) { $femRef  = (Get-ChildItem .\audio\ref\female\*_norm.wav | Sort-Object Name | Select-Object -First 1).FullName }

if (-not $maleRef -or -not $femRef) { Write-Host "No refs found."; exit 1 }
$maleRef = (Resolve-Path $maleRef).Path
$femRef  = (Resolve-Path $femRef ).Path

# --- text file ---
$textPath = ".\book_text\ab_smoke.txt"
if (-not (Test-Path $textPath)) {
@'
Привет! Это короткий тест.

Сегодня мы проверяем ударения и паузы.
Всё должно звучать естественно.
'@ | Set-Content -Encoding UTF8 $textPath
}

# --- where diag script writes (observed) ---
$diagOuts = @(".\out\diag_donu.wav", ".\out\donu.wav")
$script = ".\scripts\diag_donu.py"
if (-not (Test-Path $script)) { Write-Host "Missing $script"; exit 1 }

function Invoke-Donu {
    param([string]$refPath, [string]$finalOut)

    # delete any leftover diag outputs
    foreach($p in $diagOuts){ if(Test-Path $p){ Remove-Item $p -Force } }

    $tries = @(
        @("--engine","donu"),
        @("--model","donu"),
        @("-e","donu"),
        @("-m","donu"),
        @("--use-donu"),
        @("--donu")
    )

    $ok = $false
    foreach($t in $tries){
        Write-Host "Trying flags: $($t -join ' ')"
        # try long flags first
        python -u $script --textfile $textPath --ref "$refPath" --out $finalOut @t
        if ($LASTEXITCODE -ne 0 -and -not ($diagOuts | ForEach-Object { Test-Path $_ } | Where-Object { $_ })){
            # try short flags + short args
            python -u $script -t $textPath -r "$refPath" -o $finalOut @t
        }

        # if any diag file appeared, rename it to desired target
        foreach($p in $diagOuts){
            if (Test-Path $p){
                Move-Item -Force $p $finalOut
                $ok = $true; break
            }
        }
        if ($ok) { break }
    }

    if (-not $ok -or -not (Test-Path $finalOut)) {
        throw "Donu run failed (no output). Check console log above."
    }
}

Write-Host "Male ref:   $maleRef"
Write-Host "Female ref: $femRef"

# --- run male ---
$outMale = ".\out\ab_donu_male.wav"
Write-Host "`nGenerating Donu (male) -> $outMale"
Invoke-Donu -refPath $maleRef -finalOut $outMale
Get-Item $outMale | Format-List FullName, Length

# --- run female ---
$outFem = ".\out\ab_donu_female.wav"
Write-Host "`nGenerating Donu (female) -> $outFem"
Invoke-Donu -refPath $femRef -finalOut $outFem
Get-Item $outFem | Format-List FullName, Length

Write-Host "`nOK. Review ab_donu_male.wav / ab_donu_female.wav vs your XTTS files."
Write-Host "Tip: prefer short sentences, blank lines for pauses, keep «ё»."
