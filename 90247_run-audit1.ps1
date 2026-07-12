# ============================================================
#  VALEX ROOT BOOTSTRAP — XIPE + TEZCATLIPOCA EDITION
#  Root: C:\Users\enriq\VALEX
# ============================================================

$Root = "C:\Users\enriq\VALEX"
New-Item -ItemType Directory -Path $Root -Force | Out-Null

Write-Host "🌑 XIPE: Establishing VALEX root at $Root"

# ------------------------------------------------------------
# 1. VALEX Seed
# ------------------------------------------------------------
$SeedPath = Join-Path $Root "seed.txt"
if (-not (Test-Path $SeedPath)) {
    "seed-data-1781612368" | Set-Content $SeedPath -Encoding UTF8
    Write-Host "🌱 XIPE: Seed placed."
} else {
    Write-Host "🌱 XIPE: Seed already present."
}

# ------------------------------------------------------------
# 2. Vendor Routing
# ------------------------------------------------------------
$VendorRoutePath = Join-Path $Root "vendor-route.json"
if (-not (Test-Path $VendorRoutePath)) {
@'
{
  "explicit": {},
  "patterns": {
    "hackerone": ["hackerone.com"],
    "firefox": ["mozilla.org","firefox.com","addons.mozilla.org","mozilla.net"],
    "google": ["google.com","gstatic.com","youtube.com","android.com"],
    "bugcrowd": ["bugcrowd.com"],
    "microsoft": ["microsoft.com","windows.com","azure.com","office.com","live.com"],
    "linux": [
      "kernel.org","gnu.org","debian.org","ubuntu.com","canonical.com",
      "redhat.com","fedora.org","centos.org","suse.com","opensuse.org",
      "archlinux.org","manjaro.org","alpinelinux.org"
    ]
  },
  "fallback": "psirt"
}
'@ | Set-Content $VendorRoutePath -Encoding UTF8
    Write-Host "📡 XIPE: Vendor patterns woven."
} else {
    Write-Host "📡 XIPE: Vendor patterns already woven."
}

# ------------------------------------------------------------
# 3. GlassSubstrateAudit.psm1 — Xipe + Tezcatlipoca
# ------------------------------------------------------------
$ModulePath = Join-Path $Root "GlassSubstrateAudit.psm1"
@'
function Invoke-GlassSubstrateAudit {
    [CmdletBinding()]
    param(
        [string]$Path = "C:\",
        [string]$OutputPath = "$PSScriptRoot\VALEX-GlassSubstrate-Audit.json",
        [string]$Node = "90247_GARDENA_ALPHA",
        [string]$ValexSeedPath = "$PSScriptRoot\seed.txt",
        [string]$VendorRoutePath = "$PSScriptRoot\vendor-route.json"
    )

    $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffK"

    # XIPE: Seed = kernel of the cycle
    $valexSeed = if (Test-Path $ValexSeedPath) {
        Get-Content $ValexSeedPath -Raw
    } else {
        "NO_VALEX_SEED_FOUND"
    }

    $valexBlock = [ordered]@{
        VALEX_Seed    = $valexSeed
        VALEX_Version = "VALEX-Pipeline-1.0"
        ModuleRoot    = $PSScriptRoot
        Cycle         = "Shedding → Revelation → Renewal"
    }

    # Vendor routing
    if (Test-Path $VendorRoutePath) {
        try { $vendorRouting = Get-Content $VendorRoutePath -Raw | ConvertFrom-Json }
        catch { $vendorRouting = @{ error = "Failed to parse vendor-route.json" } }
    } else {
        $vendorRouting = @{ error = "vendor-route.json not found" }
    }

    $valexVendorBlock = [ordered]@{
        VendorRouting = $vendorRouting
        RoutingLoaded = (Test-Path $VendorRoutePath)
    }

    # XIPE: GlassSubstrate plan (shedding telemetry skin)
    $glassPlan = [ordered]@{
        Capability = "GlassSubstrate_KillSwitch"
        Mode       = "PLAN_ONLY"
        Timestamp  = $timestamp
        Telemetry  = @{ Targets=@("siq","speedInsightsBeforeSend"); Strategy="override-to-noop" }
        Analytics  = @{ Hooks=@("ga","ga4","appInsights","vortex","clarity"); Strategy="noop" }
        DomRemoval = @{ Selectors=@("vercel-speed-insights","astro-island","script[src*='vercel']") }
        Symbolism  = "Shedding the old telemetry skin to reveal the substrate."
    }

    # XIPE: Revelation — unrestricted crawl of all files
    [System.AppContext]::SetSwitch("Switch.System.IO.UseLegacyPathHandling", $false)
    [System.AppContext]::SetSwitch("Switch.System.IO.BlockLongPaths", $false)

    $files = Get-ChildItem -Path $Path -Recurse -Force -File -ErrorAction SilentlyContinue

    $auditEntries = foreach ($file in $files) {
        try { $hash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash }
        catch { $hash = "HASH_FAILED" }

        [ordered]@{
            FileName      = $file.Name
            FullPath      = $file.FullName
            SizeBytes     = $file.Length
            LastWriteTime = $file.LastWriteTimeUtc.ToString("o")
            IntegrityHash = $hash
        }
    }

    # TEZCATLIPOCA: Obsidian Mirror Protocol
    $ObsidianMirror = [ordered]@{
        Reflection = "System state captured without alteration."
        Distortion = @{
            HashFailures = ($auditEntries | Where-Object { $_.IntegrityHash -eq "HASH_FAILED" }).Count
            HiddenFiles  = ($files | Where-Object { $_.Attributes -match "Hidden" }).Count
            SystemFiles  = ($files | Where-Object { $_.Attributes -match "System" }).Count
        }
        Memory = @{
            Seed       = $valexSeed
            ModuleRoot = $PSScriptRoot
        }
        Night = @{
            TotalFiles  = $files.Count
            ShadowFiles = ($files | Where-Object { $_.Attributes -match "Hidden|System" }).Count
        }
        Fate = "Will be sealed by chain-of-custody hash."
    }

    # XIPE: Renewal — the new ledger
    $auditReport = [ordered]@{
        SessionID   = "GlassSubstrate_Audit_" + (Get-Date -Format "yyyyMMdd_HHmmss")
        Timestamp   = $timestamp
        Node        = $Node
        TargetPath  = $Path
        FileCount   = $auditEntries.Count
        VALEX       = $valexBlock
        VALEX_VendorRouting = $valexVendorBlock
        GlassSubstratePlan  = $glassPlan
        ObsidianMirror      = $ObsidianMirror
        Files       = $auditEntries
    }

    # Chain-of-custody hash (Fate)
    $json = $auditReport | ConvertTo-Json -Depth 10 -Compress
    $hash = (Get-FileHash -InputStream ([IO.MemoryStream]::new([Text.Encoding]::UTF8.GetBytes($json))) -Algorithm SHA256).Hash
    $auditReport["IntegrityHash"] = $hash

    # Write artifact
    $auditReport | ConvertTo-Json -Depth 10 | Set-Content $OutputPath -Encoding UTF8

    Write-Host "🌕 XIPE/TEZCATLIPOCA: Audit written to $OutputPath" -ForegroundColor Green
}

Export-ModuleMember -Function Invoke-GlassSubstrateAudit
'@ | Set-Content $ModulePath -Encoding UTF8

Write-Host "🎭 XIPE: GlassSubstrateAudit module created."

# ------------------------------------------------------------
# 4. run-audit.ps1
# ------------------------------------------------------------
$RunnerPath = Join-Path $Root "run-audit.ps1"
@"
Import-Module "$Root\GlassSubstrateAudit.psm1" -Force
Invoke-GlassSubstrateAudit -Path "C:\"
"@ | Set-Content $RunnerPath -Encoding UTF8

Write-Host "🌅 XIPE: Audit runner created."

# ------------------------------------------------------------
# 5. Execute audit immediately
# ------------------------------------------------------------
Write-Host "🔍 XIPE/TEZCATLIPOCA: Beginning revelation..."
& $RunnerPath
```
# ------------------------------------------------------------
#  HUMMINGBIRD + OWL PROTOCOL
#  (Active Sweep + Silent Depth Scan)
# ------------------------------------------------------------

# HUMMINGbird: rapid-motion active sweep metrics
$Hummingbird = [ordered]@{
    Symbol        = "Huitzilopochtli"
    Meaning       = "Relentless forward motion; active enumeration."
    SweepRate     = ($files.Count)
    FastPaths     = ($files | Where-Object { $_.Length -lt 1048576 }).Count  # <1MB
    Notes         = "Represents the rapid traversal phase of the audit."
}

# OWL: silent, hidden, shadowed file detection
$Owl = [ordered]@{
    Symbol        = "Messenger of the Deep"
    Meaning       = "Stillness, hidden layers, shadowed structures."
    HiddenFiles   = ($files | Where-Object { $_.Attributes -match 'Hidden' }).Count
    SystemFiles   = ($files | Where-Object { $_.Attributes -match 'System' }).Count
    LockedFiles   = ($auditEntries | Where-Object { $_.IntegrityHash -eq 'HASH_FAILED' }).Count
    Notes         = "Represents the silent inspection of concealed or inaccessible paths."
}

$HummingbirdOwlProtocol = [ordered]@{
    Hummingbird = $Hummingbird
    Owl         = $Owl
    Cycle       = "Motion ↔ Stillness"
    Purpose     = "Dual-phase enumeration: rapid sweep + deep shadow scan."
}
