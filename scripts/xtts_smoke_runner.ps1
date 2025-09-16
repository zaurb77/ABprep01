# create text

@'
Привет! Это короткий тест.

Сегодня мы проверяем ударения и паузы.
Всё должно звучать естественно.
'@ | Set-Content -Encoding UTF8 .\book_text\ab_smoke.txt

# Pull the male ref from your voicepack and run the script
$maleRef = ((Get-Content .\audio\ref\voicepack.json | ConvertFrom-Json).voices |
            Where-Object { $_.name -eq 'ru_male_neutral' }).ref
python .\scripts\xtts_smoke.py --textfile .\book_text\ab_smoke.txt --ref $maleRef --out .\out\ab_xtts_male.wav
