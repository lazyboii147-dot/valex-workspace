# ============================================================================
# FILE: Process-Intake-Final.ps1
# DESCRIPTION: Production-Ready Master Ingestion & Forensic Validation Engine
# AUTHORIZATION: Station 90247-Alpha Core Pipeline
# ============================================================================

# 1. Establish Environmental Configuration Contexts
$SourcePattern = "$HOME\VALEX*"
$TargetBaseDir = "C:\Users\enriq\VALEX"
$EvidenceDir   = Join-Path -Path $TargetBaseDir -ChildPath "02_EVIDENCE\processed"
$AuditLogPath  = Join-Path -Path $TargetBaseDir -ChildPath "04_LOGS\audit_trail\main_audit.log"
$HashFilePath  = Join-Path -Path $TargetBaseDir -ChildPath "08_PROOFS\hashes\evidence_hashes.sha256"

Write-Host "[*] Initializing automated operational pass..." -ForegroundColor Cyan

# 2. Programmatic Verification of Storage Infrastructure
$RequiredDirs = @(
    $EvidenceDir, 
    (Split-Path -Path $AuditLogPath -Parent), 
    (Split-Path -Path $HashFilePath -Parent)
)

foreach ($Dir in $RequiredDirs) {
    if (-not (Test-Path -Path $Dir)) { 
        New-Item -ItemType Directory -Path $Dir -Force | Out-Null
        Write-Host "[+] Infrastructure created: $Dir" -ForegroundColor Gray
    }
}

# 3. Queue Building (Forcing Flat File Filtering to Dodge Loop Collisions)
$TargetFiles = Get-ChildItem -Path $SourcePattern -File -ErrorAction SilentlyContinue

if (-not $TargetFiles) { 
    Write-Host "[*] Ingestion queue empty. Staging area clear." -ForegroundColor Green
    exit 
}

Write-Host "[!] Located $($TargetFiles.Count) matching file(s) for verification." -ForegroundColor Cyan

# 4. Batch Processing Pass
foreach ($File in $TargetFiles) {
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $BaseName  = $File.BaseName
    $Extension = $File.Extension
    $NewName   = $File.Name
    $DestinationPath = Join-Path -Path $EvidenceDir -ChildPath $NewName
    
    # Non-Destructive Auto-Renaming Collision Solver
    $Counter = 1
    while (Test-Path -Path $DestinationPath) {
        $NewName = $BaseName + "_" + $Counter + $Extension
        $DestinationPath = Join-Path -Path $EvidenceDir -ChildPath $NewName
        $Counter++
    }
    
    try {
        # Generate Definitive Hash Checksum
        $FileHash = (Get-FileHash -Path $File.FullName -Algorithm SHA256).Hash
        
        # Execute Atomic Data Relocation
        Move-Item -Path $File.FullName -Destination $DestinationPath -Force
        
        # Write Explicit Log Entries (Protected using sub-expression syntax to lock string values)
        $LogEntry = "$Timestamp | INTAKE | $($NewName) | $($FileHash) | Safe Finalized"
        Add-Content -Path $AuditLogPath -Value $LogEntry
        
        $HashEntry = "$( $FileHash )  $( $DestinationPath )"
        Add-Content -Path $HashFilePath -Value $HashEntry
        
        Write-Host "[+] Successfully Processed: $($File.Name) -> $NewName" -ForegroundColor Green
    } catch {
        Write-Error "Processing exception on targeting entity $($File.Name): $_"
    }
}

# 5. Clean Pipeline Deactivation (Simplified to protect quote boundaries)
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "OPERATIONAL SWEEP COMPLETE. PIPELINE RECOUPED AND RETIRED." -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan