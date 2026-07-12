param([string]$Path, [string]$Desc)
 = "C:\Users\enriq\VALEX\02_EVIDENCE\raw\disk_images"
 = "C:\Users\enriq\VALEX\04_LOGS\audit_trail\main_audit.log"
 = "C:\Users\enriq\VALEX\08_PROOFS\hashes\evidence_hashes.sha256"
 = (Get-FileHash -Path $Path -Algorithm SHA256).Hash
Move-Item -Path $Path -Destination $targetDir -Force
 = "2026-06-20 14:53:30 | INTAKE | $Path | $hash | $Desc"
Add-Content -Path $auditLog -Value $logEntry
Add-Content -Path $hashFile -Value "$hash  $targetDir\$Path"
