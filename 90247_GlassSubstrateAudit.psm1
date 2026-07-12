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
