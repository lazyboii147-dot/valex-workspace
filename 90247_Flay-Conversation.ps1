# [FLAY_PROTOCOL: v1.0]
# Forensic Ledger & Analysis Yield: Conversation Node Extraction
param(
    [Parameter(Mandatory=$true)]
    [string]$ConversationId,
    [string]$TargetApp = "M365"
)

$FlayDir = "C:\Forensics\XIPE-TOTECH\Artifacts\Flay_Yields"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$ReportPath = "$FlayDir\FlayYield_$($ConversationId)_$($Timestamp).json"

# Forensic Logic: Simulate the 'sidebarConversationAction' telemetry observed in Ft component
$TelemetryEvent = [PSCustomObject]@{
    Source         = "sidebarConversationAction"
    Scenario       = "toggleMenu"
    ConversationId = $ConversationId
    Type           = $TargetApp
    Status         = "Analyzed"
    Policy         = "CannotShareNorEdit"
}

# Yield Extraction
$TelemetryEvent | ConvertTo-Json | Out-File $ReportPath

# Integrity Sealing: Append to soilLedger
$Hash = (Get-FileHash -Path $ReportPath -Algorithm SHA256).Hash
Add-Content -Path "C:\Forensics\XIPE-TOTECH\Logs\soilLedger.log" -Value "$Timestamp | Node: $ConversationId | Hash: $Hash"

Write-Host "[+] Flay successful. Yield sealed in soilLedger." -ForegroundColor Green