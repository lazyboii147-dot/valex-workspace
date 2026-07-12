$basePath = "C:\Users\enriq\VALEX"
$folders = @("01_INTAKE\case_manifest", "01_INTAKE\authorizations", "02_EVIDENCE\raw\disk_images", "02_EVIDENCE\raw\network_captures", "02_EVIDENCE\raw\memory_dumps", "02_EVIDENCE\raw\pending", "02_EVIDENCE\processed\extracted_artifacts", "02_EVIDENCE\processed\timeline_analysis", "03_INTELLIGENCE\threat_intel", "03_INTELLIGENCE\leads", "04_LOGS\audit_trail", "04_LOGS\console_history", "05_NOTES\investigator_logs", "05_NOTES\meetings", "06_REPORTS\interim", "06_REPORTS\final_disclosure", "07_EXPORTS\disclosure_package", "08_PROOFS\hashes", "08_PROOFS\signatures")
foreach ($folder in $folders) { New-Item -Path (Join-Path $basePath $folder) -ItemType Directory -Force | Out-Null }
Set-Content -Path "$basePath\01_INTAKE\case_manifest\README.md" -Value "# CASE MANIFEST`nCase ID: `nScope Definition: `nAnalyst Assigned: `nDate Initiated: $(Get-Date -Format 'yyyy-MM-dd')"
New-Item -Path "$basePath\08_PROOFS\hashes\evidence_hashes.sha256" -ItemType File -Force | Out-Null
New-Item -Path "$basePath\04_LOGS\audit_trail\main_audit.log" -ItemType File -Force | Out-Null
# Create Intake.ps1
$intakeContent = "param([string]`$Path, [string]`$Desc)`n$targetDir = ""$basePath\02_EVIDENCE\raw\disk_images""`n$auditLog = ""$basePath\04_LOGS\audit_trail\main_audit.log""`n$hashFile = ""$basePath\08_PROOFS\hashes\evidence_hashes.sha256""`n$hash = (Get-FileHash -Path `$Path -Algorithm SHA256).Hash`nMove-Item -Path `$Path -Destination `$targetDir -Force`n$logEntry = ""$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') | INTAKE | $(Split-Path `$Path -Leaf) | `$hash | `$Desc""`nAdd-Content -Path `$auditLog -Value `$logEntry`nAdd-Content -Path `$hashFile -Value ""$`hash  `$targetDir\$(Split-Path `$Path -Leaf)"""
$intakeContent | Out-File "$basePath\Intake.ps1"
# Create Monitor.ps1
$monitorContent = "$pendingDir = ""$basePath\02_EVIDENCE\pending""`nGet-ChildItem -Path `$pendingDir -File | ForEach-Object { .\Intake.ps1 -Path `$_.FullName -Desc ""Automated sync"" }"
$monitorContent | Out-File "$basePath\Monitor.ps1"
Write-Host "VALEX Environment fully initialized at $basePath" -ForegroundColor Green
