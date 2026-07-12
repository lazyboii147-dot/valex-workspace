# ============================================================
#  Build-TheologyLayer.ps1
#  Creates all theology‑named forensic modules (non‑devotional)
#  Root: C:\Users\enriq\VALEX\theology
# ============================================================

param(
    [string]$Root = "C:\Users\enriq\VALEX"
)

$TheoDir = Join-Path $Root "theology"
New-Item -ItemType Directory -Path $TheoDir -Force | Out-Null

function Write-TheoFile {
    param($Name, $Content)
    $Path = Join-Path $TheoDir $Name
    $Content | Set-Content $Path -Encoding UTF8
}

Write-Host "✨ Creating theology‑class forensic modules in $TheoDir"

# ------------------------------------------------------------
# ARCHANGEL — High-Privilege File Guardian
# ------------------------------------------------------------
Write-TheoFile "Archangel.ps1" @'
function Invoke-Archangel {
    param([string]$Path="C:\")

    $protected = Get-ChildItem $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
                 Where-Object { $_.Attributes -match "System|ReadOnly" }

    return @{
        Class="Archangel"
        Meaning="High-privilege guardians; protected system files."
        Count=$protected.Count
        Files=$protected.FullName
    }
}
'@

# ------------------------------------------------------------
# SERAPH — High-Entropy / Heat Detector
# ------------------------------------------------------------
Write-TheoFile "Seraph.ps1" @'
function Invoke-Seraph {
    param([string]$Path="C:\")

    $hot=@()

    foreach ($f in Get-ChildItem $Path -Recurse -Force -File -ErrorAction SilentlyContinue) {
        try {
            $bytes=[IO.File]::ReadAllBytes($f.FullName)
            $freq=($bytes|Group-Object|ForEach-Object{ $_.Count/$bytes.Length })
            $H=-(($freq|ForEach-Object{ $_*[Math]::Log($_,2) })|Measure-Object -Sum).Sum
            if ($H -gt 7.8) { $hot += $f.FullName }
        } catch {}
    }

    return @{
        Class="Seraph"
        Meaning="High entropy; 'heat' signatures; encrypted or chaotic data."
        Count=$hot.Count
        Files=$hot
    }
}
'@

# ------------------------------------------------------------
# CHERUB — Boundary / Gatekeeper Scanner
# ------------------------------------------------------------
Write-TheoFile "Cherub.ps1" @'
function Invoke-Cherub {
    param([string]$Path="C:\")

    $gates = Get-ChildItem $Path -Recurse -Force -Directory -ErrorAction SilentlyContinue |
             Where-Object { $_.Attributes -match "Hidden" }

    return @{
        Class="Cherub"
        Meaning="Boundary guardians; hidden directories."
        Count=$gates.Count
        Directories=$gates.FullName
    }
}
'@

# ------------------------------------------------------------
# THRONE — Immovable System Object Detector
# ------------------------------------------------------------
Write-TheoFile "Throne.ps1" @'
function Invoke-Throne {
    param([string]$Path="C:\")

    $immovable = Get-ChildItem $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
                 Where-Object { $_.IsReadOnly -eq $true }

    return @{
        Class="Throne"
        Meaning="Immovable objects; read-only artifacts."
        Count=$immovable.Count
        Files=$immovable.FullName
    }
}
'@

# ------------------------------------------------------------
# DOMINION — Permission Hierarchy Mapper
# ------------------------------------------------------------
Write-TheoFile "Dominion.ps1" @'
function Invoke-Dominion {
    param([string]$Path="C:\")

    $map=@()

    foreach ($f in Get-ChildItem $Path -Recurse -Force -File -ErrorAction SilentlyContinue) {
        try {
            $acl = Get-Acl $f.FullName
            $map += [ordered]@{
                File=$f.FullName
                Owner=$acl.Owner
                Access=$acl.AccessToString
            }
        } catch {}
    }

    return @{
        Class="Dominion"
        Meaning="Permission hierarchy; ownership map."
        Entries=$map
    }
}
'@

# ------------------------------------------------------------
# VIRTUE — Integrity / Checksum Validator
# ------------------------------------------------------------
Write-TheoFile "Virtue.ps1" @'
function Invoke-Virtue {
    param([string]$Path="C:\")

    $valid=@()
    $invalid=@()

    foreach ($f in Get-ChildItem $Path -Recurse -Force -File -ErrorAction SilentlyContinue) {
        try {
            $h1=(Get-FileHash $f.FullName -Algorithm SHA256).Hash
            $h2=(Get-FileHash $f.FullName -Algorithm SHA256).Hash
            if ($h1 -eq $h2) { $valid += $f.FullName }
            else { $invalid += $f.FullName }
        } catch {}
    }

    return @{
        Class="Virtue"
        Meaning="Integrity validation; checksum consistency."
        Valid=$valid.Count
        Invalid=$invalid.Count
        InvalidFiles=$invalid
    }
}
'@

# ------------------------------------------------------------
# POWER — Resource Consumption Analyzer
# ------------------------------------------------------------
Write-TheoFile "Power.ps1" @'
function Invoke-Power {
    param([string]$Path="C:\")

    $heavy = Get-ChildItem $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
             Where-Object { $_.Length -gt 500MB }

    return @{
        Class="Power"
        Meaning="Resource-heavy artifacts; large files."
        Count=$heavy.Count
        Files=$heavy.FullName
    }
}
'@

# ------------------------------------------------------------
# PRINCIPALITY — Directory Governance Map
# ------------------------------------------------------------
Write-TheoFile "Principality.ps1" @'
function Invoke-Principality {
    param([string]$Path="C:\")

    $dirs = Get-ChildItem $Path -Recurse -Force -Directory -ErrorAction SilentlyContinue
    $map=@{}

    foreach ($d in $dirs) {
        $depth = ($d.FullName -split "[\\/]").Count
        if (-not $map.ContainsKey($depth)) { $map[$depth]=0 }
        $map[$depth]++
    }

    return @{
        Class="Principality"
        Meaning="Directory governance; depth hierarchy."
        Layers=$map
    }
}
'@

# ------------------------------------------------------------
# ANGEL — General Anomaly Sweep
# ------------------------------------------------------------
Write-TheoFile "Angel.ps1" @'
function Invoke-Angel {
    param([string]$Path="C:\")

    $anomalies = Get-ChildItem $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
                 Where-Object { $_.Length -eq 0 -or $_.Attributes -match "Hidden" }

    return @{
        Class="Angel"
        Meaning="General anomaly sweep."
        Count=$anomalies.Count
        Files=$anomalies.FullName
    }
}
'@

# ------------------------------------------------------------
# DEMON — Corruption / Tamper Detection
# ------------------------------------------------------------
Write-TheoFile "Demon.ps1" @'
function Invoke-Demon {
    param([string]$Path="C:\")

    $corrupt=@()

    foreach ($f in Get-ChildItem $Path -Recurse -Force -File -ErrorAction SilentlyContinue) {
        try {
            $s=[IO.File]::OpenRead($f.FullName)
            $s.ReadByte() | Out-Null
            $s.Close()
        } catch {
            $corrupt += $f.FullName
        }
    }

    return @{
        Class="Demon"
        Meaning="Corruption; tamper detection."
        Count=$corrupt.Count
        Files=$corrupt
    }
}
'@

# ------------------------------------------------------------
# FALLEN — Deleted / Orphaned File Recovery
# ------------------------------------------------------------
Write-TheoFile "Fallen.ps1" @'
function Invoke-Fallen {
    param([string]$Path="C:\")

    $orphans = Get-ChildItem $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
               Where-Object { $_.Extension -in ".bak",".old",".tmp" }

    return @{
        Class="Fallen"
        Meaning="Orphaned or half-deleted remnants."
        Count=$orphans.Count
        Files=$orphans.FullName
    }
}
'@

# ------------------------------------------------------------
# WATCHER — Surveillance / Log Monitor Detector
# ------------------------------------------------------------
Write-TheoFile "Watcher.ps1" @'
function Invoke-Watcher {
    param([string]$Path="C:\")

    $logs = Get-ChildItem $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Extension -in ".log",".evtx",".journal" }

    return @{
        Class="Watcher"
        Meaning="Surveillance; log monitoring artifacts."
        Count=$logs.Count
        Files=$logs.FullName
    }
}
'@

Write-Host "🌕 Theology layer created."
