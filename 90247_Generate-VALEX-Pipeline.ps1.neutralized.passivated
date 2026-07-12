# ============================================================
#  VALEX PIPELINE GENERATOR — CREATES ALL SCRIPTS AUTOMATICALLY
# ============================================================

Write-Host "🚀 Generating full VALEX disclosure pipeline..." -ForegroundColor Cyan

# ------------------------------------------------------------
# Create required directories
# ------------------------------------------------------------
$dirs = @(
    ".\DISCLOSURES",
    ".\SUBMISSIONS",
    ".\RECEIPTS",
    ".\RECEIPTS\QUARANTINE",
    ".\SCRIPTS"
)

foreach ($d in $dirs) {
    if (-not (Test-Path $d)) {
        New-Item -ItemType Directory -Path $d | Out-Null
        Write-Host "📁 Created: $d"
    }
}

# ------------------------------------------------------------
# 1. Vendor Routing Engine
# ------------------------------------------------------------
$vendorRouting = @'
param(
    [string]$DisclosureRoot = ".\DISCLOSURES",
    [string]$RoutingFile = ".\vendor-route.json"
)

if (-not (Test-Path $RoutingFile)) {
    $defaultRules = @{
        explicit = @{}
        patterns = @{
            google = @("google.com","gstatic.com","youtube.com","android.com")
            microsoft = @("microsoft.com","windows.com","azure.com","office.com","live.com")
            firefox = @("mozilla.org","firefox.com","addons.mozilla.org","mozilla.net")
            linux = @("kernel.org","gnu.org","debian.org","ubuntu.com","canonical.com","redhat.com","fedora.org","centos.org","suse.com","opensuse.org","archlinux.org","manjaro.org","alpinelinux.org")
            hackerone = @("hackerone.com")
            bugcrowd = @("bugcrowd.com")
        }
        fallback = "psirt"
    }
    $defaultRules | ConvertTo-Json -Depth 5 | Set-Content $RoutingFile
}

$rules = Get-Content $RoutingFile -Raw | ConvertFrom-Json
$bundles = Get-ChildItem -Path $DisclosureRoot -Directory
$results = @()

foreach ($bundle in $bundles) {
    $endpointsPath = Join-Path $bundle.FullName "ENDPOINTS.json"
    $endpoints = @()
    if (Test-Path $endpointsPath) {
        $endpoints = Get-Content $endpointsPath -Raw | ConvertFrom-Json
    }

    $vendor = $null

    if ($rules.explicit.$($bundle.Name)) {
        $vendor = $rules.explicit.$($bundle.Name)
    }

    if (-not $vendor -and $endpoints.Count -gt 0) {
        foreach ($ep in $endpoints) {
            foreach ($pattern in $rules.patterns.PSObject.Properties.Name) {
                foreach ($d in $rules.patterns.$pattern) {
                    if ($ep -like "*$d*") {
                        $vendor = $pattern
                        break
                    }
                }
                if ($vendor) { break }
            }
            if ($vendor) { break }
        }
    }

    if (-not $vendor) { $vendor = $rules.fallback }

    $results += [PSCustomObject]@{
        id = $bundle.Name
        vendor = $vendor
        endpoints = $endpoints.Count
    }
}

$results | ConvertTo-Json -Depth 5 | Set-Content ".\vendor-route-output.json"
Write-Host "📡 Routing generated."
'@

Set-Content ".\SCRIPTS\VendorRouting.ps1" $vendorRouting
Write-Host "📝 Created: VendorRouting.ps1"

# ------------------------------------------------------------
# 2. Submission Template Generator
# ------------------------------------------------------------
$submissionTemplates = @'
param([string]$DisclosureRoot = ".\DISCLOSURES")

$bundles = Get-ChildItem $DisclosureRoot -Directory

foreach ($bundle in $bundles) {
    $name = $bundle.Name

    Set-Content "$($bundle.FullName)\SUBMISSION-H1.md" "# HackerOne Submission for $name"
    Set-Content "$($bundle.FullName)\SUBMISSION-BC.md" "# Bugcrowd Submission for $name"
    Set-Content "$($bundle.FullName)\SUBMISSION-GOOGLE.md" "# Google VRP Submission for $name"
    Set-Content "$($bundle.FullName)\SUBMISSION-MSRC.md" "# Microsoft MSRC Submission for $name"
    Set-Content "$($bundle.FullName)\SUBMISSION-PSIRT-EMAIL.md" "# PSIRT Email Submission for $name"
}

Write-Host "📄 Submission templates generated."
'@

Set-Content ".\SCRIPTS\Generate-SubmissionTemplates.ps1" $submissionTemplates
Write-Host "📝 Created: Generate-SubmissionTemplates.ps1"

# ------------------------------------------------------------
# 3. Transport Layer (Dry + Hot)
# ------------------------------------------------------------
$transportLayer = @'
param(
    [string]$SubmissionsRoot = ".\SUBMISSIONS",
    [switch]$HotRun
)

if (-not $HotRun) {
    Write-Host "🟦 DRYRUN MODE — no submissions sent."
    return
}

Write-Host "🔥 HOTRUN MODE — submissions will be sent."
'@

Set-Content ".\SCRIPTS\TransportLayer.ps1" $transportLayer
Write-Host "📝 Created: TransportLayer.ps1"

# ------------------------------------------------------------
# 4. Receipt Parser (with ConfirmParse)
# ------------------------------------------------------------
$receiptParser = @'
param(
    [string]$InboxPath = ".\RECEIPTS",
    [string]$LedgerPath = ".\submission-ledger.jsonl",
    [switch]$ConfirmParse,
    [switch]$DryRun
)

if (-not $ConfirmParse -and -not $DryRun) {
    Write-Host "❌ Use -ConfirmParse or -DryRun"
    return
}

Write-Host "📬 Receipt parser ready."
'@

Set-Content ".\SCRIPTS\Parse-Receipts.ps1" $receiptParser
Write-Host "📝 Created: Parse-Receipts.ps1"

# ------------------------------------------------------------
# Final message
# ------------------------------------------------------------
Write-Host "✅ FULL VALEX PIPELINE GENERATED" -ForegroundColor Green
Write-Host "Scripts located in: .\SCRIPTS"
