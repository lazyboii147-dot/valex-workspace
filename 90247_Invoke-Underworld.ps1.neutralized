# ============================================================
#  INVOKE UNDERWORLD — NINE LAYERS OF MICTLAN (STANDALONE)
#  This file loads all deity modules and performs the full
#  nine‑layer traversal without depending on any other script.
# ============================================================

param(
    [string]$Path = "C:\",
    [string]$DeityRoot = "C:\Users\enriq\VALEX\deities"
)

Write-Host "🜂 Entering the Underworld... Nine layers will be traversed."

# ------------------------------------------------------------
# Load all deity modules
# ------------------------------------------------------------
. (Join-Path $DeityRoot "Mictlantecuhtli.ps1")
. (Join-Path $DeityRoot "Mictecacihuatl.ps1")
. (Join-Path $DeityRoot "Xolotl.ps1")
. (Join-Path $DeityRoot "TlalocDeep.ps1")
. (Join-Path $DeityRoot "Itzpapalotl.ps1")

# ------------------------------------------------------------
#  NINE LAYERS OF MICTLAN — FORENSIC INTERPRETATION
# ------------------------------------------------------------

# 1. Itzcuintlan — The Dog’s Crossing (Xolotl)
$Layer1 = Invoke-Xolotl -Path $Path

# 2. Tepectli Monamictlan — The Crushing Hills
$Layer2 = [ordered]@{
    Deity   = "Tepectli Monamictlan"
    Meaning = "Crushing pressure; filesystem stress."
    LargeFiles = (Get-ChildItem -Path $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
                  Where-Object { $_.Length -gt 1GB }).Count
}

# 3. Iztepetl — The Obsidian Mountain
$Layer3 = [ordered]@{
    Deity   = "Iztepetl"
    Meaning = "Obsidian shards; sharp failures."
    HashFailures = $Layer1.Count
}

# 4. Itzehecayan — The Obsidian Wind (Fragmentation)
$Layer4 = Invoke-Itzpapalotl -Path $Path

# 5. Paniecatacoyan — The Place Where People Float (Temp states)
$Layer5 = [ordered]@{
    Deity   = "Paniecatacoyan"
    Meaning = "Floating states; temp artifacts."
    TempFiles = (Get-ChildItem -Path $Path -Recurse -Force -File -ErrorAction SilentlyContinue |
                 Where-Object { $_.Extension -in ".tmp",".temp",".partial",".crdownload" }).Count
}

# 6. Timiminaloayan — The Place of Arrows (Corruption)
$Layer6 = Invoke-TlalocDeep -Path $Path

# 7. Teocoyohuehualoyan — The Place Where Hearts Are Eaten (Metadata loss)
$Layer7 = Invoke-Mictecacihuatl -Path $Path

# 8. Izmictlan Apochcalolca — The Misty Place (Uncertain states)
$Layer8 = [ordered]@{
    Deity   = "Izmictlan Apochcalolca"
    Meaning = "Mist; uncertainty; unreadable metadata."
    UnknownAttributes = $Layer7.Count
}

# 9. Chicunamictlan — The Final Layer (Mictlantecuhtli)
$Layer9 = Invoke-Mictlantecuhtli -Path $Path

# ------------------------------------------------------------
#  RETURN NINE-LAYER STRUCTURE
# ------------------------------------------------------------

$Underworld = [ordered]@{
    Layer1_Itzcuintlan           = $Layer1
    Layer2_TepectliMonamictlan   = $Layer2
    Layer3_Iztepetl              = $Layer3
    Layer4_Itzehecayan           = $Layer4
    Layer5_Paniecatacoyan        = $Layer5
    Layer6_Timiminaloayan        = $Layer6
    Layer7_Teocoyohuehualoyan    = $Layer7
    Layer8_IzmictlanApochcalolca = $Layer8
    Layer9_Chicunamictlan        = $Layer9
    Summary = "Nine-layer traversal complete."
}

Write-Host "🜄 Underworld traversal complete. All nine layers mapped."

return $Underworld
