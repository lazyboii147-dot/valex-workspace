param(
    [switch]$HotRun,
    [switch]$DryRun
)

Write-Host "🚀 VALEX Orchestrator Starting..." -ForegroundColor Cyan

$required = @(".\DISCLOSURES", ".\SUBMISSIONS", ".\RECEIPTS", ".\SCRIPTS")
foreach ($dir in $required) {
    if (-not (Test-Path $dir)) {
        Write-Host "❌ Missing required directory: $dir" -ForegroundColor Red
        return
    }
}

Write-Host "📡 Running Vendor Routing..." -ForegroundColor Yellow
& ".\SCRIPTS\VendorRouting.ps1"

Write-Host "📄 Generating Submission Templates..." -ForegroundColor Yellow
& ".\SCRIPTS\Generate-SubmissionTemplates.ps1"

if ($HotRun) {
    Write-Host "🔥 HOTRUN MODE — Submissions will be sent." -ForegroundColor Red
    & ".\SCRIPTS\TransportLayer.ps1" -HotRun
} else {
    Write-Host "🟦 DRYRUN MODE — No submissions sent." -ForegroundColor Cyan
    & ".\SCRIPTS\TransportLayer.ps1"
}

Write-Host "📬 Parsing Receipts..." -ForegroundColor Yellow

if ($HotRun) {
    & ".\SCRIPTS\Parse-Receipts.ps1" -ConfirmParse
} else {
    & ".\SCRIPTS\Parse-Receipts.ps1" -DryRun
}

Write-Host "✅ VALEX Orchestration Complete." -ForegroundColor Green
