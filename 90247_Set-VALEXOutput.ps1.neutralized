# ============================================================
#  Set-VALEXOutput.ps1
#  Creates a unified output location for ALL VALEX modules.
#  Works on Windows, Linux, and WSL (/mnt/c).
# ============================================================

param(
    [string]$Base = "C:\Users\enriq\VALEX\output",
    [switch]$Timestamped
)

# Normalize for Linux/WSL
if ($Base -like "/mnt/*") {
    $Base = $Base
} else {
    $Base = $Base -replace "/", "\"
}

# Create base directory
if (-not (Test-Path $Base)) {
    New-Item -ItemType Directory -Path $Base -Force | Out-Null
}

# Create timestamped subfolder if requested
if ($Timestamped) {
    $stamp = (Get-Date -Format "yyyyMMdd_HHmmss")
    $Final = Join-Path $Base $stamp
    New-Item -ItemType Directory -Path $Final -Force | Out-Null
} else {
    $Final = $Base
}

# Return object
$Output = [ordered]@{
    BasePath   = $Base
    FinalPath  = $Final
    Timestamp  = (Get-Date).ToString("o")
    Exists     = $true
}

Write-Host "📁 VALEX Output Directory Ready:"
Write-Host "➡️  $Final"

return $Output
