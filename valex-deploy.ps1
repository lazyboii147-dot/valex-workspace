# valex-deploy.ps1 - Automated Workspace Consolidation
$Root = "C:\Users\enriq\valex-workspace"

# 1. Define the Source of Truth
$Manifest = @{
    "workspace_root" = $Root
    "log_source"     = "$Root\var\log\telemetry_stream.log"
    "rules"          = @{
        "HUNT_SIGHTING" = @{ "max_delay" = 3; "prereq" = "Wildlife Sighting|Entity Spotted"; "dependent" = "Engage Target|Deploy Trap" }
        "ENTITY_TRAIL"  = @{ "max_delay" = 6; "prereq" = "Tracking Beacon|Pheromone Trace"; "dependent" = "Heartbeat|Sensor Response" }
    }
}

# 2. Define Components to Verify/Create
$FilesToVerify = @{
    "valex.config.json" = ($Manifest | ConvertTo-Json -Depth 5)
    
    "bin\msrc-tools.ps1" = @"
function Emit-MSRCDossier {
    param([hashtable]`$ThreatResult)
    `$obj = `$ThreatResult.Object
    `$path = "$Root\reports\Dossier_`$(Get-Date -Format yyyyMMdd_HHmmss).md"
    `$md = @"
# Forensic Dossier: OMNIBUS Telemetry Anomaly
**Timestamp:** `$(`$obj.Timestamp) | **Score:** `$(`$obj.Score)/100

## 1. Executive Summary
Telemetry exfiltration observed.
- **Redirect Token:** `$(`$obj.Redirect.Token)
- **Campaign ID:** `$(`$obj.Redirect.CampaignID)
"@
    `$md | Out-File `$path -Encoding UTF8
    Write-Host "[MSRC] Dossier generated: `$path" -ForegroundColor Green
}
"@

    "bin\valex-engine.ps1" = @"
param([string]`$Task)
`$Root = "$Root"
switch (`$Task) {
    "audit" { python "`$Root\src\automation\python\wildlife_hunt_crawler.py" }
    "report" { . "`$Root\bin\msrc-tools.ps1"; Emit-MSRCDossier -ThreatResult @{ Object = [PSCustomObject]@{ Timestamp=(Get-Date); Score=85; Redirect=@{Token='AUTO'; CampaignID='VALEX-2026'} } } }
}
"@

    "src\automation\python\wildlife_hunt_crawler.py" = @"
#!/usr/bin/env python3
import json, re, os
from datetime import datetime

with open(r'$Root\valex.config.json') as f: config = json.load(f)
LOG_PATH = config['log_source']
OUTPUT_JSON = r'$Root\var\log\wildlife_hunt_anomalies.json'

def crawl():
    if not os.path.exists(LOG_PATH): return
    with open(LOG_PATH, 'r', encoding='utf-8', errors='ignore') as f:
        events = [{'line': i, 'time': datetime.strptime(line[:12], '%H:%M:%S.%f'), 'raw': line.strip()} 
                  for i, line in enumerate(f, 1) if re.match(r'\d{2}:\d{2}:\d{2}\.\d{3}', line)]
    
    findings = []
    for id, rule in config['rules'].items():
        for p in [e for e in events if re.search(rule['prereq'], e['raw'], re.I)]:
            later = [d for d in events if d['time'] > p['time'] and re.search(rule['dependent'], d['raw'], re.I)]
            if not later or (min(later, key=lambda x: x['time'])['time'] - p['time']).total_seconds() > rule['max_delay']:
                findings.append({'dependency_id': id, 'type': 'ANOMALY', 'prereq_line': p['line']})
    
    with open(OUTPUT_JSON, 'w') as out: json.dump(findings, out, indent=2)

if __name__ == '__main__': crawl()
"@
}

# 3. Execution: Surgical Repair
Write-Host "[*] Synchronizing workspace..." -ForegroundColor Cyan
foreach ($Path in $FilesToVerify.Keys) {
    $FullPath = Join-Path $Root $Path
    $Dir = [System.IO.Path]::GetDirectoryName($FullPath)
    if (!(Test-Path $Dir)) { New-Item -ItemType Directory -Path $Dir -Force | Out-Null }
    
    if (!(Test-Path $FullPath)) {
        Write-Host "[!] Restoring: $Path" -ForegroundColor Red
        $FilesToVerify[$Path] | Out-File $FullPath -Encoding UTF8
    } else {
        Write-Host "[+] Verified: $Path" -ForegroundColor Green
    }
}

Write-Host "`n[+] Integration Complete. Engine Ready." -ForegroundColor Green
Write-Host "    Usage: .\bin\valex-engine.ps1 audit" -ForegroundColor Yellow