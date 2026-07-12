# ============================================================================
# FILE: Stage-90247-Assets.ps1
# DESCRIPTION: Upstream Staging Provider & Automated Ingestion Trigger (90247 Pattern)
# AUTHORIZATION: Station 90247-Alpha Pipeline Feed
# ============================================================================

# 1. Define Feed Origins and Pipeline Drop Zones
$ScanOriginDir = "C:\Users\enriq\VALEX\"
$PipelineDrop  = "C:\Users\enriq"
$EnginePath    = "C:\Users\enriq\VALEX\Process-Intake-Final.ps1"

Write-Host "[*] Scanning staging origin for 90247 assets: $ScanOriginDir" -ForegroundColor Cyan

# 2. Verify Ingestion Folders Exist Natively
if (-not (Test-Path -Path $ScanOriginDir)) {
    New-Item -ItemType Directory -Path $ScanOriginDir -Force | Out-Null
    Write-Host "[+] Created empty intake repository folder: $ScanOriginDir" -ForegroundColor Gray
}

# 3. Gather Untracked Assets from Intake Root
$PendingItems = Get-ChildItem -Path (Join-Path -Path $ScanOriginDir -ChildPath "*") -File -ErrorAction SilentlyContinue

if (-not $PendingItems) {
    Write-Host "[*] No staging assets found inside 01_INTAKE folder. Feed clear." -ForegroundColor Green
    exit
}

Write-Host "[!] Found $($PendingItems.Count) asset(s) ready to be pushed to the 90247 pipeline." -ForegroundColor Yellow

# 4. Format, Rename, and Inject Assets into the Pattern Zone
foreach ($Item in $PendingItems) {
    # Check if name already starts with the pattern prefix to preserve indexing tags
    if ($Item.Name -like "90247*") {
        $StagedName = $Item.Name
    } else {
        $StagedName = "90247_" + $Item.Name
    }
    
    $DestinationTarget = Join-Path -Path $PipelineDrop -ChildPath $StagedName

    try {
        # Safe migration check to dodge pipeline blockages
        if (Test-Path -Path $DestinationTarget) {
            Remove-Item -Path $DestinationTarget -Force
        }

        # Shift asset directly into the engine search radius
        Move-Item -Path $Item.FullName -Destination $DestinationTarget -Force
        Write-Host "[>] Staged & Primed: $($Item.Name) -> $StagedName" -ForegroundColor Gray
    } catch {
        Write-Error "Failed staging deployment sequence for object $($Item.Name): $_"
    }
}

# 5. Automated Execution Handshake
Write-Host "[*] Handshake engaged. Initializing Master Ingestion Engine..." -ForegroundColor Cyan
if (Test-Path -Path $EnginePath) {
    & $EnginePath
} else {
    Write-Error "Master Engine not found at path: $EnginePath"
}