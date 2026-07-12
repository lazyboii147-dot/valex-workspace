 = "C:\Users\enriq\VALEX\02_EVIDENCE\pending"
Get-ChildItem -Path $pendingDir -File | ForEach-Object { .\Intake.ps1 -Path $_.FullName -Desc "Automated sync" }
