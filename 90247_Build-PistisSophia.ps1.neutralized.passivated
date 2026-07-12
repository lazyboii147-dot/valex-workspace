# ============================================================
#  Build-PistisSophia.ps1
#  Creates all Pistis Sophia–themed forensic modules
#  Root: C:\Users\enriq\VALEX\pistis_sophia
# ============================================================

param(
    [string]$Root = "C:\Users\enriq\VALEX"
)

$PSDir = Join-Path $Root "pistis_sophia"
New-Item -ItemType Directory -Path $PSDir -Force | Out-Null

function Write-PSFile {
    param($Name, $Content)
    $Path = Join-Path $PSDir $Name
    $Content | Set-Content $Path -Encoding UTF8
}

Write-Host "✨ Creating Pistis Sophia modules in $PSDir"

# ------------------------------------------------------------
# 1. Pistis — Faith / Integrity Consistency Scanner
# ------------------------------------------------------------
Write-PSFile "Pistis.ps1" @'
function Invoke-Pistis {
    param([string]$Path = "C:\")

    $files = Get-ChildItem -Path $Path -Recurse -Force -File -ErrorAction SilentlyContinue
    $consistent = @()
    $inconsistent = @()

    foreach ($f in $files) {
        try {
            $hash1 = (Get-FileHash -Path $f.FullName -Algorithm SHA256 -ErrorAction Stop).Hash
            $hash2 = (Get-FileHash -Path $f.FullName -Algorithm SHA256 -ErrorAction Stop).Hash
            if ($hash1 -eq $hash2) { $consistent += $f.FullName }
            else { $inconsistent += $f.FullName }
        } catch {}
    }

    return [ordered]@{
        Aspect       = "Pistis"
        Meaning      = "Integrity consistency; faithfulness of state."
        Consistent   = $consistent.Count
        Inconsistent = $inconsistent.Count
        InconsistentFiles = $inconsistent
    }
}
'@

# ------------------------------------------------------------
# 2. Sophia — Wisdom / Anomaly Density Analyzer
# ------------------------------------------------------------
Write-PSFile "Sophia.ps1" @'
function Invoke-Sophia {
    param([string]$Path = "C:\")

    $files = Get-ChildItem -Path $Path -Recurse -Force -File -ErrorAction SilentlyContinue
    $small  = $files | Where-Object { $_.Length -lt 1024 }
    $large  = $files | Where-Object { $_.Length -gt 104857600 }
    $hidden = $files | Where-Object { $_.Attributes -match "Hidden" }

    return [ordered]@{
        Aspect      = "Sophia"
        Meaning     = "Wisdom via anomaly density."
        TotalFiles  = $files.Count
        SmallFiles  = $small.Count
        LargeFiles  = $large.Count
        HiddenFiles = $hidden.Count
    }
}
'@

# ------------------------------------------------------------
# 3. Aeons — Layered Depth / Directory Strata Map
# ------------------------------------------------------------
Write-PSFile "Aeons.ps1" @'
function Invoke-Aeons {
    param([string]$Path = "C:\")

    $items = Get-ChildItem -Path $Path -Recurse -Force -File -ErrorAction SilentlyContinue
    $layers = @{}

    foreach ($i in $items) {
        $depth = ($i.FullName.TrimEnd('\','/') -split '[\\/]').Count
        if (-not $layers.ContainsKey($depth)) { $layers[$depth] = 0 }
        $layers[$depth]++
    }

    return [ordered]@{
        Aspect = "Aeons"
        Meaning = "Layered depth; directory strata."
        Layers = $layers
    }
}
'@

# ------------------------------------------------------------
# 4. Veils — Permission / Visibility Boundary Scanner
# ------------------------------------------------------------
Write-PSFile "Veils.ps1" @'
function Invoke-Veils {
    param([string]$Path = "C:\")

    $files = Get-ChildItem -Path $Path -Recurse -Force -File -ErrorAction SilentlyContinue
    $hidden = $files | Where-Object { $_.Attributes -match "Hidden" }
    $system = $files | Where-Object { $_.Attributes -match "System" }
    $denied = @()

    foreach ($f in $files) {
        try { Get-Content $f.FullName -ErrorAction Stop | Out-Null }
        catch { $denied += $f.FullName }
    }

    return [ordered]@{
        Aspect       = "Veils"
        Meaning      = "Boundaries of visibility and access."
        HiddenCount  = $hidden.Count
        SystemCount  = $system.Count
        DeniedCount  = $denied.Count
        DeniedFiles  = $denied
    }
}
'@

# ------------------------------------------------------------
# 5. Repentances — Error / Failure Ledger
# ------------------------------------------------------------
Write-PSFile "Repentances.ps1" @'
function Invoke-Repentances {
    param([string]$Path = "C:\")

    $files = Get-ChildItem -Path $Path -Recurse -Force -File -ErrorAction SilentlyContinue
    $failures = @()

    foreach ($f in $files) {
        try { Get-FileHash -Path $f.FullName -Algorithm SHA256 -ErrorAction Stop | Out-Null }
        catch {
            $failures += [ordered]@{
                File  = $f.FullName
                Error = $_.Exception.Message
            }
        }
    }

    return [ordered]@{
        Aspect    = "Repentances"
        Meaning   = "Confessed failures; error ledger."
        FailCount = $failures.Count
        Failures  = $failures
    }
}
'@

# ------------------------------------------------------------
# 6. TreasuryOfLight — High-Value / Critical File Locator
# ------------------------------------------------------------
Write-PSFile "TreasuryOfLight.ps1" @'
function Invoke-TreasuryOfLight {
    param([string]$Path = "C:\")

    $patterns = @("*.pfx","*.pem","*.key","*.kdbx","*.vault","*.secret","*.config","*.env")
    $treasure = @()

    foreach ($p in $patterns) {
        $treasure += Get-ChildItem -Path $Path -Recurse -Force -Filter $p -ErrorAction SilentlyContinue
    }

    return [ordered]@{
        Aspect    = "TreasuryOfLight"
        Meaning   = "High-value secrets and critical artifacts."
        Count     = $treasure.Count
        Files     = $treasure.FullName
    }
}
'@

# ------------------------------------------------------------
# 7. PistisSophia-Orchestrator — Unified Pistis Sophia Layer
# ------------------------------------------------------------
Write-PSFile "Invoke-PistisSophia.ps1" @'
function Invoke-PistisSophia {
    param([string]$Path = "C:\")

    $root = Split-Path $MyInvocation.MyCommand.Path -Parent

    . (Join-Path $root "Pistis.ps1")
    . (Join-Path $root "Sophia.ps1")
    . (Join-Path $root "Aeons.ps1")
    . (Join-Path $root "Veils.ps1")
    . (Join-Path $root "Repentances.ps1")
    . (Join-Path $root "TreasuryOfLight.ps1")

    $pistis   = Invoke-Pistis -Path $Path
    $sophia   = Invoke-Sophia -Path $Path
    $aeons    = Invoke-Aeons -Path $Path
    $veils    = Invoke-Veils -Path $Path
    $repents  = Invoke-Repentances -Path $Path
    $treasury = Invoke-TreasuryOfLight -Path $Path

    return [ordered]@{
        Layer        = "PistisSophia"
        Path         = $Path
        Pistis       = $pistis
        Sophia       = $sophia
        Aeons        = $aeons
        Veils        = $veils
        Repentances  = $repents
        TreasuryOfLight = $treasury
        Timestamp    = (Get-Date).ToString("o")
    }
}
'@

Write-Host "🌕 Pistis Sophia modules created."
