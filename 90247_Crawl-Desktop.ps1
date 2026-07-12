# ============================================
#  DIRECTORY CRAWLER FOR SPECIFIED PATH
#  + GLASSSUBSTRATE PLAN INTEGRATION
# ============================================

param(
    [string]$TargetPath = "C:\Users\enriq\Desktop",
    [string]$OutputPath = ".\Desktop-GlassSubstrate-Audit.json",
    [string]$Node = "90247_GARDENA_ALPHA"
)

$timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ss.fffK"

# 1. GlassSubstrate PLAN object
$glassPlan = [ordered]@{
    Capability = "GlassSubstrate_KillSwitch"
    Mode       = "PLAN_ONLY"
    Timestamp  = $timestamp

    Telemetry = [ordered]@{
        Targets  = @("siq", "speedInsightsBeforeSend")
        Strategy = "override-to-noop"
    }

    Analytics = [ordered]@{
        Hooks    = @("ga", "ga4", "appInsights", "vortex", "clarity")
        Strategy = "noop"
    }

    DomRemoval = [ordered]@{
        Selectors = @(
            "vercel-speed-insights",
            "astro-island",
            "script[src*='vercel']"
        )
    }

    Notes = "Capability documented only. Execution requires explicit operator toggle."
}

# 2. Crawl the target directory
$files = Get-ChildItem -Path $TargetPath -Recurse -File -ErrorAction SilentlyContinue

$auditEntries = foreach ($file in $files) {
    $hash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash

    [ordered]@{
        FileName      = $file.Name
        FullPath      = $file.FullName
        SizeBytes     = $file.Length
        LastWriteTime = $file.LastWriteTimeUtc.ToString("o")
        IntegrityHash = $hash
    }
}

# 3. Build final audit object
$auditReport = [ordered]@{
    SessionID   = "Desktop_GlassSubstrate_Audit_" + (Get-Date -Format "yyyyMMdd_HHmmss")
    Timestamp   = $timestamp
    Node        = $Node
    Status      = "CRAWL_COMPLETE"
    TargetPath  = $TargetPath
    FileCount   = $auditEntries.Count
    GlassSubstratePlan = $glassPlan
    Files       = $auditEntries
}

# 4. Chain-of-custody hash
$json = $auditReport | ConvertTo-Json -Depth 10 -Compress
$hash = (Get-FileHash -InputStream ([IO.MemoryStream]::new([Text.Encoding]::UTF8.GetBytes($json))) -Algorithm SHA256).Hash
$auditReport["IntegrityHash"] = $hash

# 5. Write artifact
$auditReport | ConvertTo-Json -Depth 10 | Set-Content $OutputPath -Encoding UTF8

Write-Host "Success: Desktop audit written to $OutputPath" -ForegroundColor Green
