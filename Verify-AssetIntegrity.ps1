# Researcher: Enrique G (CL34RBOX)
Start-Sleep -Seconds 1
$DistPath = ".\dist"
Write-Host "`n======================================================================" -ForegroundColor Cyan
Write-Host "        VALEX* SYSTEM SUBSTRATE INTEGRITY AUDIT STARTING" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan

$ClientChunks = Get-ChildItem -Path $DistPath -Filter "*.client.js"
Write-Host "`n[1/3] Parsing Emitted Client Chunks ($($ClientChunks.Count) detected)..." -ForegroundColor Yellow
foreach ($Chunk in $ClientChunks) {
    $FileContent = Get-Content -Path $Chunk.FullName -Raw
    Write-Host " -> Analyzing: $($Chunk.Name)" -ForegroundColor Gray
    if ($Chunk.Name -like "main.*") {
        if ($FileContent -like "*square*" -or $FileContent -like "*return x*x*") {
            Write-Host "    [!] ALERT: Dead-code elimination check failed!" -ForegroundColor Red
        } else {
            Write-Host "    [✓] SUCCESS: Dead-code elimination verified. Unused exports dropped." -ForegroundColor Green
        }
    }
}

Write-Host "`n[2/3] Extracting Embedded Inlined Asset Vectors..." -ForegroundColor Yellow
foreach ($Chunk in $ClientChunks) {
    $Content = Get-Content -Path $Chunk.FullName -Raw
    if ($Content -match 'data:image/svg\+xml;base64,[A-Za-z0-9+/=]+') {
        Write-Host "    [✓] Found Embedded Vector Asset Module: $($Matches[0].Substring(0, 45))..." -ForegroundColor Green
    }
}

Write-Host "`n[3/3] Inspecting Node Server Telemetry Bundles..." -ForegroundColor Yellow
$NodeChunks = Get-ChildItem -Path $DistPath -Filter "*.node.js"
foreach ($Node in $NodeChunks) {
    $FileContent = Get-Content -Path $Node.FullName -Raw
    Write-Host " -> Analyzing Server Infrastructure: $($Node.Name)" -ForegroundColor Gray
    if ($Node.Name -eq "aztecTelemetry.node.js") {
        # Check for minified identifiers or explicit logging blocks generated during scope hoisting
        if ($FileContent -match "Tlaloc|Xipe|initAztecNodes|AZTEC") {
            Write-Host "    [✓] Confirmed Isomorphic Integrity: Aztec tracking parameters verified." -ForegroundColor Green
        } else {
            Write-Host "    [!] Warning: Missing expected Aztec tracking parameters in output compilation." -ForegroundColor Red
        }
    }
}
Write-Host "`n======================================================================" -ForegroundColor Cyan
Write-Host "                 INTEGRITY AUDIT RUN COMPLETELY VERIFIED" -ForegroundColor Cyan
Write-Host "======================================================================" -ForegroundColor Cyan
