# RUN from: D:\Projects\AudioBooks\ABprep01
# If PowerShell shows (.venv), first close that terminal or run: deactivate
Remove-Item -Recurse -Force .\.venv  # deletes old env
py -3.10 -m venv .\.venv
.\.venv\Scripts\Activate.ps1
python -V
