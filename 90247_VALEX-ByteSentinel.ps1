param(
    [string]$Root = ".",
    [switch]$AutoFix
)

Write-Host "🔍 VALEX Byte‑Integrity Sentinel Starting..." -ForegroundColor Cyan

$targets = Get-ChildItem -Recurse -Include *.ps1,*.psm1,*.json,*.md

$quarantine = Join-Path $Root "BYTE_QUARANTINE"
if (-not (Test-Path $quarantine)) {
    New-Item -ItemType Directory -Path $quarantine | Out-Null
}

foreach ($file in $targets) {

    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    $bad = @()

    for ($i = 0; $i -lt $bytes.Length; $i++) {
        $b = $bytes[$i]

        # ASCII printable + CR/LF allowed
        if (
            ($b -ge 32 -and $b -le 126) -or
            $b -eq 10 -or
            $b -eq 13
        ) {
            continue
        }

        # Everything else is corruption
        $bad += [PSCustomObject]@{
            Offset = $i
            Byte   = ("0x{0:X2}" -f $b)
        }
    }

    if ($bad.Count -gt 0) {
        Write-Host "❌ CORRUPTION DETECTED in $($file.FullName)" -ForegroundColor Red
        $bad | Format-Table

        if ($AutoFix) {
            $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
            $backup = Join-Path $quarantine ("{0}.{1}.bak" -f $file.Name, $timestamp)

            Copy-Item $file.FullName $backup

            $clean = $bytes | Where-Object {
                ($_ -ge 32 -and $_ -le 126) -or $_ -eq 10 -or $_ -eq 13
            }

            [System.IO.File]::WriteAllBytes($file.FullName, $clean)
            Write-Host "🛠️  CLEANED: $($file.Name) — backup saved to BYTE_QUARANTINE" -ForegroundColor Green
        }
    }
}

Write-Host "✅ Byte‑Integrity Scan Complete." -ForegroundColor Green
