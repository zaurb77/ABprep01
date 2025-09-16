# scripts/ABprep06b-git_snapshot.ps1
# Commits current changes and pushes to origin/main.

$ErrorActionPreference = "Stop"

# 0) Ensure Git is available
try { git --version | Out-Null } catch {
  Write-Host "Git not found. Install: winget install --id Git.Git -e"
  exit 1
}

# 1) Init repo if needed and switch to main
if (-not (Test-Path .\.git)) {
  git init
  git branch -M main
}

# 2) Warn if identity not set (not fatal)
$uName  = git config user.name
$uEmail = git config user.email
if (-not $uName -or -not $uEmail) {
  Write-Host "Tip: set identity if needed:"
  Write-Host "  git config user.name  \"Your Name\""
  Write-Host "  git config user.email \"you@example.com\""
}

# 3) Ensure remote "origin"
$hasOrigin = (git remote 2>$null) -contains 'origin'
if (-not $hasOrigin) {
  git remote add origin https://github.com/zaurb77/ABprep01.git
}

# 4) Stage everything and commit if there are changes
git add -A

git diff --cached --quiet
if ($LASTEXITCODE -eq 1) {
  $ts = Get-Date -Format "yyyy-MM-dd HH:mm"
  git commit -m "Snapshot: XTTS/Donu smoke + listening_notes ($ts)"
} else {
  Write-Host "Nothing new to commit."
}

# 5) Push to origin/main
git push -u origin main
Write-Host "Pushed to origin/main."
