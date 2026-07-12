# ============================================================
#  BUILD-VALEX-UNIVERSE.PS1
#  Creates ALL classes, functions, deities, entities, ghosts,
#  creatures, and supporting modules in one automated pass.
# ============================================================

$Root = "C:\Users\enriq\VALEX"
New-Item -ItemType Directory -Path $Root -Force | Out-Null

Write-Host "🌑 Building VALEX Universe at $Root"

# ------------------------------------------------------------
#  Create Subdirectories
# ------------------------------------------------------------
$Dirs = @(
    "deities",
    "entities",
    "ghosts",
    "classes",
    "functions"
)

foreach ($d in $Dirs) {
    New-Item -ItemType Directory -Path (Join-Path $Root $d) -Force | Out-Null
}

Write-Host "📁 Directories created."

# ------------------------------------------------------------
#  Helper: Write file
# ------------------------------------------------------------
function Write-VALEXFile {
    param($Path, $Content)
    $Content | Set-Content $Path -Encoding UTF8
}

# ============================================================
#  DEITIES (Underworld)
# ============================================================

$DeityDir = Join-Path $Root "deities"

Write-VALEXFile (Join-Path $DeityDir "Mictlantecuhtli.ps1") @'
function Invoke-Mictlantecuhtli {
    param([string]$Path = "C:\")
    $files = Get-ChildItem $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
             Where-Object { $_.LastWriteTimeUtc -lt (Get-Date).AddYears(-3) }
    return @{ Deity="Mictlantecuhtli"; Count=$files.Count; Files=$files.FullName }
}
'@

Write-VALEXFile (Join-Path $DeityDir "Mictecacihuatl.ps1") @'
function Invoke-Mictecacihuatl {
    param([string]$Path = "C:\")
    $files = Get-ChildItem $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
             Where-Object { $_.CreationTime -eq $null -or $_.LastWriteTime -eq $null }
    return @{ Deity="Mictecacihuatl"; Count=$files.Count; Files=$files.FullName }
}
'@

Write-VALEXFile (Join-Path $DeityDir "Xolotl.ps1") @'
function Invoke-Xolotl {
    param([string]$Path = "C:\")
    $failed=@()
    foreach ($f in Get-ChildItem $Path -Recurse -Force -File -ErrorAction SilentlyContinue) {
        try { Get-FileHash $f.FullName -Algorithm SHA256 -ErrorAction Stop | Out-Null }
        catch { $failed += $f.FullName }
    }
    return @{ Deity="Xolotl"; Count=$failed.Count; Files=$failed }
}
'@

Write-VALEXFile (Join-Path $DeityDir "TlalocDeep.ps1") @'
function Invoke-TlalocDeep {
    param([string]$Path = "C:\")
    $corrupt=@()
    foreach ($f in Get-ChildItem $Path -Recurse -Force -File -ErrorAction SilentlyContinue) {
        try { $s=[IO.File]::OpenRead($f.FullName);$s.ReadByte()|Out-Null;$s.Close() }
        catch { $corrupt += $f.FullName }
    }
    return @{ Deity="TlalocDeep"; Count=$corrupt.Count; Files=$corrupt }
}
'@

Write-VALEXFile (Join-Path $DeityDir "Itzpapalotl.ps1") @'
function Invoke-Itzpapalotl {
    param([string]$Path = "C:\")
    $patterns="*.tmp","*.partial","*.crdownload","*.download","*.part"
    $shards=@()
    foreach ($p in $patterns) {
        $shards += Get-ChildItem $Path -Recurse -Force -Filter $p -ErrorAction SilentlyContinue
    }
    return @{ Deity="Itzpapalotl"; Count=$shards.Count; Files=$shards.FullName }
}
'@

Write-Host "🜂 Deity modules created."

# ============================================================
#  ENTITIES (Creatures)
# ============================================================

$EntityDir = Join-Path $Root "entities"

Write-VALEXFile (Join-Path $EntityDir "Ghoul.ps1") @'
function Invoke-Ghoul {
    param([string]$Path="C:\")
    $files=Get-ChildItem $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
           Where-Object { $_.Length -lt 512 }
    return @{ Entity="Ghoul"; Count=$files.Count; Files=$files.FullName }
}
'@

Write-VALEXFile (Join-Path $EntityDir "Goblin.ps1") @'
function Invoke-Goblin {
    param([string]$Path="C:\")
    $weird=Get-ChildItem $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
           Where-Object { $_.Name -match "[^a-zA-Z0-9\.\-_]+" }
    return @{ Entity="Goblin"; Count=$weird.Count; Files=$weird.FullName }
}
'@

Write-VALEXFile (Join-Path $EntityDir "Witch.ps1") @'
function Invoke-Witch {
    param([string]$Path="C:\")
    $scripts=Get-ChildItem $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
             Where-Object { $_.Extension -in ".ps1",".sh",".py" -and $_.Attributes -match "Hidden" }
    return @{ Entity="Witch"; Count=$scripts.Count; Files=$scripts.FullName }
}
'@

Write-VALEXFile (Join-Path $EntityDir "Wizard.ps1") @'
function Invoke-Wizard {
    param([string]$Path="C:\")
    $entropy=@()
    foreach ($f in Get-ChildItem $Path -Recurse -Force -File -ErrorAction SilentlyContinue) {
        try {
            $bytes=[IO.File]::ReadAllBytes($f.FullName)
            $freq=($bytes|Group-Object|ForEach-Object{ $_.Count/$bytes.Length })
            $H=-(($freq|ForEach-Object{ $_*[Math]::Log($_,2) })|Measure-Object -Sum).Sum
            if ($H -gt 7.5) { $entropy += $f.FullName }
        } catch {}
    }
    return @{ Entity="Wizard"; Count=$entropy.Count; Files=$entropy }
}
'@

Write-VALEXFile (Join-Path $EntityDir "Fiend.ps1") @'
function Invoke-Fiend {
    param([string]$Path="C:\")
    $denied=@()
    foreach ($f in Get-ChildItem $Path -Recurse -Force -File -ErrorAction SilentlyContinue) {
        try { Get-Content $f.FullName -ErrorAction Stop | Out-Null }
        catch { $denied += $f.FullName }
    }
    return @{ Entity="Fiend"; Count=$denied.Count; Files=$denied }
}
'@

Write-VALEXFile (Join-Path $EntityDir "Zombie.ps1") @'
function Invoke-Zombie {
    param([string]$Path="C:\")
    $z=Get-ChildItem $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
       Where-Object { $_.Length -eq 0 -or $_.Extension -in ".tmp",".bak",".old" }
    return @{ Entity="Zombie"; Count=$z.Count; Files=$z.FullName }
}
'@

Write-Host "🜄 Entity modules created."

# ============================================================
#  GHOST SCRIPTS
# ============================================================

$GhostDir = Join-Path $Root "ghosts"

Write-VALEXFile (Join-Path $GhostDir "GhostScanner.ps1") @'
function Invoke-GhostScanner {
    param([string]$Path="C:\")
    $ghosts=Get-ChildItem $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match "ghost|shade|specter|wraith|phantom|spirit" }
    return @{ Ghosts=$ghosts.FullName; Count=$ghosts.Count }
}
'@

Write-Host "👻 Ghost modules created."

# ============================================================
#  CLASSES & FUNCTIONS (Generic)
# ============================================================

$ClassDir = Join-Path $Root "classes"
$FuncDir  = Join-Path $Root "functions"

Write-VALEXFile (Join-Path $ClassDir "VALEXObject.ps1") @'
class VALEXObject {
    [string]$Name
    [string]$Type
    [hashtable]$Data
    VALEXObject([string]$n,[string]$t,[hashtable]$d){$this.Name=$n;$this.Type=$t;$this.Data=$d}
}
'@

Write-VALEXFile (Join-Path $FuncDir "Merge-VALEX.ps1") @'
function Merge-VALEX {
    param([Parameter(ValueFromPipeline)]$Items)
    $merged=@{}
    foreach ($i in $Items) { $merged[$i.Name]=$i.Data }
    return $merged
}
'@

Write-Host "🧩 Classes and functions created."

# ============================================================
#  DONE
# ============================================================

Write-Host "🌕 VALEX Universe build complete."
