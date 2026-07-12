# =====================================================================
# XENOPHILE CAPABILITY PACK – V@L3X_URL_TARGET_SWITCH MODULE
# =====================================================================
# Type: Standalone, Namespace-Scoped Forensic Ingestion Node
# Environment Compatibility: Windows PowerShell 5.1 / Native VT100 ANSI
# Function: Adaptive Target Heuristic Mapping and Script Passivation
# =====================================================================

param(
    [string]$WorkspacePath = "\Users\enriq\valex-workspace",
    [string]$TargetUrl     = $(Read-Host "Enter target URL for Xenophile routing")
)

# ---------------------------------------------------------------------
# TERMINAL GRAPHICS DEFINITIONS (ANSI VT100 CODES)
# ---------------------------------------------------------------------
$Esc      = [char]27
$Reset    = "$Esc[0m"
$Bold     = "$Esc[1m"
$Dim      = "$Esc[2m"
$Cyan     = "$Esc[36m"
$Green    = "$Esc[32m"
$Yellow   = "$Esc[33m"
$Red      = "$Esc[31m"
$Magenta  = "$Esc[35m"

Write-Host "`n${Bold}${Cyan}[V@L3X_URL_TARGET_SWITCH] URL-driven adaptive routing initialized...${Reset}"
Write-Host "    ${Dim}[*] Input Telemetry Stream Vector:${Reset} ${Bold}$TargetUrl${Reset}"

# ---------------------------------------------------------------------
# 1. SUBSYSTEM PATH RESOLUTION
# ---------------------------------------------------------------------
$FlayRoot       = Join-Path $WorkspacePath "flay_layer"
$JsSignatureDir = Join-Path $FlayRoot "JS_BEHAVIORAL_SIGNATURES"
$XipeSubmodule  = Join-Path $JsSignatureDir "XIPE_TOTECH_MONITORS"
$ValexSubmodule = Join-Path $JsSignatureDir "VALEX_INTERCEPTORS"
$MediaSubmodule = Join-Path $FlayRoot "UX_MEDIA_STUBS"
$ImgSubmodule   = Join-Path $FlayRoot "TIMELINE_DOSSIER_IMPORTS"

# Idempotently map and verify destination layer targets
$EnforcedPaths = @($XipeSubmodule, $ValexSubmodule, $MediaSubmodule, $ImgSubmodule)
foreach ($dir in $EnforcedPaths) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }
}

# ---------------------------------------------------------------------
# 2. STRING TARGET VALIDATION & PARSING
# ---------------------------------------------------------------------
if ([string]::IsNullOrWhiteSpace($TargetUrl)) {
    Write-Host "${Bold}${Red}[!] Null or invalid execution string parameter passed. Terminating sweep.${Reset}"
    return
}

try {
    $Uri = [System.Uri]$TargetUrl
} catch {
    Write-Host "${Bold}${Red}[!] Target format does not conform to RFC URI structures. Halting routing loop.${Reset}"
    return
}

$FileName  = [System.IO.Path]::GetFileName($Uri.AbsolutePath)
$Extension = [System.IO.Path]::GetExtension($Uri.AbsolutePath).ToLower()

if ([string]::IsNullOrEmpty($FileName)) {
    # Generate explicit localized telemetry identity string for bare directory inputs
    $FileName = "root_index_capture_" + (Get-Date -Format "yyyyMMdd_HHmmss")
}

Write-Host "    ${Dim}[*] Parsed Artifact Identity:${Reset} $FileName"
Write-Host "    ${Dim}[*] Detected Attribute Extension:${Reset} $Extension"

# ---------------------------------------------------------------------
# 3. HEURISTIC EXTENSION SWITCH EXTRACTION MATRIX
# ---------------------------------------------------------------------
switch ($Extension) {
    ".js" {
        if ($FileName -match "built") {
            $TargetModule = "UX_MEDIA_STUBS"
            $FinalDest    = Join-Path $MediaSubmodule "$FileName.passivated"
        }
        elseif ($FileName -match "gemini-code" -or $Uri.Host -match "valex") {
            $TargetModule = "VALEX_INTERCEPTORS"
            $FinalDest    = Join-Path $ValexSubmodule "$FileName.passivated"
        }
        else {
            $TargetModule = "XIPE_TOTECH_MONITORS"
            $FinalDest    = Join-Path $XipeSubmodule "$FileName.passivated"
        }
    }
    
    ".jpg" {
        $TargetModule = "TIMELINE_DOSSIER_IMPORTS"
        $FinalDest    = Join-Path $ImgSubmodule $FileName
    }
    
    ".jpeg" {
        $TargetModule = "TIMELINE_DOSSIER_IMPORTS"
        $FinalDest    = Join-Path $ImgSubmodule $FileName
    }
    
    default {
        Write-Host "    ${Yellow}[!] Trailing pattern unclassified. Defaulting to VALEX fallback subsystem.${Reset}"
        $TargetModule = "VALEX_INTERCEPTORS"
        
        if ($Extension) {
            $FinalDest = Join-Path $ValexSubmodule "$FileName.passivated"
        } else {
            $FinalDest = Join-Path $ValexSubmodule "$FileName.html.passivated"
        }
    }
}

Write-Host "    ${Magenta}[~] Heuristics Resolved Subsystem:${Reset} ${Bold}$TargetModule${Reset}"

# ---------------------------------------------------------------------
# 4. DATA TRANSMISSION AND COOPERATIVE PASSIVATION
# ---------------------------------------------------------------------
try {
    $TempFilePath = Join-Path $WorkspacePath "temp_$FileName"
    
    Write-Host "    [*] Fetching low-level network trace stream..."
    # Execute native web request decoupled from Internet Explorer parser engines
    Invoke-WebRequest -Uri $TargetUrl -OutFile $TempFilePath -UseBasicParsing -TimeoutSec 15
    
    if (Test-Path $TempFilePath) {
        # Secure move to isolated FLAY destination path layer
        Copy-Item -Path $TempFilePath -Destination $FinalDest -Force
        Remove-Item -Path $TempFilePath -Force
        
        Write-Host "    ${Green}[+] Forensic Ingestion Successful:${Reset} $FileName ──► $TargetModule"
    }
} catch {
    Write-Host "${Bold}${Red}[!] Network transport request aborted or file system lock encountered. Transmission terminated.${Reset}"
    if (Test-Path $TempFilePath) { Remove-Item -Path $TempFilePath -Force }
    return
}

# ---------------------------------------------------------------------
# 5. FORENSIC SIGNATURE GENERATION MATRIX (LIVE ARTIFACT SEEDING)
# ---------------------------------------------------------------------
if (Test-Path $FinalDest) {
    Write-Host "    [*] Seeding localized behavioral tracking telemetry signature..."
    
    $SignatureModel = @{
        "id"                 = "FLAY_SIG_ADAPTIVE_" + $FileName.ToUpper().Replace(".", "_")
        "sourceUrl"          = $TargetUrl
        "resolvedSubsystem"  = $TargetModule
        "ingestionTimestamp" = "$(Get-Date -ToUniversalTime -Format "yyyy-MM-ddTHH:mm:ssZ")"
        "systemTags"         = @("URL-Driven-Ingestion", "Passivated-Forensic-Node")
        "neutralized"        = $true
    }
    
    $SigFilename = "FLAY_SIG_" + [System.IO.Path]::GetFileNameWithoutExtension($FileName) + ".json"
    $TargetSigPath = Split-Path -Parent $FinalDest
    
    $SignatureModel | ConvertTo-Json -Depth 4 | Out-File -FilePath (Join-Path $TargetSigPath $SigFilename) -Encoding UTF8 -Force
    Write-Host "    ${Green}[+] Dynamic verification trace committed to parent module context.${Reset}"
}

Write-Host "${Green}[V@L3X_URL_TARGET_SWITCH] Execution routing pass successfully terminated.${Reset}\n"