# =====================================================================
# 90247-SecOps.psm1
# Unified PowerShell Security Toolkit
# Node 90247 – Gardena, CA
# =====================================================================

# -----------------------------
# SQLMAP PASSIVE AUDIT
# -----------------------------
function Invoke-90247SqlmapPassiveAudit {
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][string]$TargetUrl)

    Write-Host "[*] Running passive sqlmap audit on $TargetUrl..."
    python3 sqlmap.py `
        -u $TargetUrl `
        --batch `
        --level=1 `
        --risk=1 `
        --dbs `
        --tables `
        --columns `
        --smart `
        --no-cast `
        --no-escape `
        --flush-session
}

# -----------------------------
# SQLMAP PIPELINE
# -----------------------------
function Invoke-90247SqlmapPipeline {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$TargetUrl,
        [string]$FlayScriptPath = "./bin/xipe_totec_flay.ps1"
    )

    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ")
    $logOut = "logs/sqlmap_audit_$timestamp.log"
    New-Item -ItemType Directory -Force -Path (Split-Path $logOut) | Out-Null

    python3 sqlmap.py -u $TargetUrl --batch --dbs | Out-File -Encoding utf8 $logOut

    if (Test-Path $FlayScriptPath) { & $FlayScriptPath $logOut }

    gpg --armor --sign $logOut
}

# -----------------------------
# SRI HASH (SHA512 → BASE64)
# -----------------------------
function Get-90247SRIHash {
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][string]$Url)

    $tmp = New-TemporaryFile
    try {
        Invoke-WebRequest -Uri $Url -OutFile $tmp -ErrorAction Stop | Out-Null
        $hash = Get-FileHash -Path $tmp -Algorithm SHA512
        $hex = $hash.Hash
        $bytes = -split ($hex -replace '..', '0x$& ')
        $base64 = [Convert]::ToBase64String($bytes)

        [PSCustomObject]@{
            Url          = $Url
            Sha512Hex    = $hex
            Sha512Base64 = $base64
        }
    } finally {
        Remove-Item $tmp -Force
    }
}

# -----------------------------
# RANGE / 206 PROBE
# -----------------------------
function Test-90247RangeProbe {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$Url,
        [int]$Count = 10
    )

    1..$Count | ForEach-Object {
        $start = $_ * 1000000
        $end   = $start + 999999

        try {
            $resp = Invoke-WebRequest `
                -Uri $Url `
                -Headers @{ "Range" = "bytes=$start-$end" } `
                -Method GET `
                -ErrorAction Stop

            [PSCustomObject]@{
                Index        = $_
                StatusCode   = $resp.StatusCode
                ContentRange = $resp.Headers["Content-Range"]
            }
        } catch {
            [PSCustomObject]@{
                Index        = $_
                StatusCode   = "Error"
                ContentRange = $_.Exception.Message
            }
        }
    }
}

# -----------------------------
# WORKBENCH PURGE
# -----------------------------
function Invoke-90247WorkbenchPurge {
    [CmdletBinding()]
    param(
        [string]$BundlePath = "./bundle.b64",
        [string]$ZipPath    = "/tmp/OMNIBUS_forensic_disclosure_20260515.zip",
        [string]$StagingDir = "/tmp/OMNIBUS_upload_20260515/"
    )

    if (Test-Path $BundlePath) { Clear-Content $BundlePath; Remove-Item $BundlePath -Force }
    if (Test-Path $ZipPath)    { Clear-Content $ZipPath;    Remove-Item $ZipPath -Force }
    if (Test-Path $StagingDir) { Remove-Item $StagingDir -Recurse -Force }
}

# -----------------------------
# ENVIRONMENT SANITIZER
# -----------------------------
function Protect-90247EnvJson {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$InputJsonPath,
        [string]$OutputJsonPath = "./environment_sanitized.json",
        [string[]]$SensitiveKeys = @("captchaKey","authToken","apiKeys","secret","clientSecret")
    )

    $envObj = Get-Content $InputJsonPath -Raw | ConvertFrom-Json

    foreach ($key in $SensitiveKeys) {
        if ($envObj.PSObject.Properties.Name -contains $key) {
            $envObj.PSObject.Properties.Remove($key)
        }
    }

    $envObj | ConvertTo-Json -Depth 10 | Set-Content $OutputJsonPath -Encoding UTF8
}

# -----------------------------
# WASM INVENTORY PARSER
# -----------------------------
function Get-90247BrowserWasmModules {
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][string]$WasmInventoryJsonPath)

    $mods = Get-Content $WasmInventoryJsonPath -Raw | ConvertFrom-Json
    $mods | Select-Object name, url, size, hash
}

# -----------------------------
# TELEMETRY PATCH JS GENERATOR
# -----------------------------
function New-90247TelemetryPatchScript {
    [CmdletBinding()]
    param([string]$BeaconId = "G-CSLL4ZEK4L")

    @"
(function () {
    const TAG = '[90247-DAP-VINDICATED]';
    try {
        if (window.oCONFIG) { Object.freeze(window.oCONFIG); }
    } catch (e) {}

    const origSend = XMLHttpRequest.prototype.send;
    XMLHttpRequest.prototype.send = function (body) {
        try {
            const payload = typeof body === 'string' ? body : '';
            if (payload.includes('$BeaconId')) { return; }
        } catch (e) {}
        return origSend.apply(this, arguments);
    };
})();
"@
}

# -----------------------------
# CSP REPORT-ONLY TESTER
# -----------------------------
function Test-90247CspReportOnly {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$ReportUri,
        [string]$ViolatedDirective = "script-src",
        [string]$BlockedUri = "https://example.com/malicious.js"
    )

    $body = @{
        "csp-report" = @{
            "document-uri"       = "https://test.local/"
            "violated-directive" = $ViolatedDirective
            "blocked-uri"        = $BlockedUri
            "original-policy"    = "default-src 'self'; report-uri $ReportUri"
        }
    } | ConvertTo-Json -Depth 5

    Invoke-WebRequest -Uri $ReportUri -Method POST -Body $body -ContentType "application/csp-report" -ErrorAction SilentlyContinue
}

# -----------------------------
# EXPORT ALL
# -----------------------------
Export-ModuleMember -Function *-90247*
