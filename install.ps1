# ---------------------------------------------------------------
#  Aigoo - one-line installer (public)
#
#  In PowerShell:
#    irm https://raw.githubusercontent.com/billwuatenlab/Aigoo/main/install.ps1 | iex
#
#  Reads the latest version from VERSION, downloads Aigoo_V<ver>.zip from that
#  tag, checks its SHA256, extracts it and runs the installer inside.
#  If the internal AIGO edition is on this PC, the installer removes it first.
#  Pure ASCII on purpose.
# ---------------------------------------------------------------
& {
    $ErrorActionPreference = 'Stop'
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $repo = 'billwuatenlab/Aigoo'
    $work = $null

    function Get-WithRetry($url, $outFile) {
        foreach ($wait in 0, 10, 30) {
            if ($wait) { Write-Host "  Retrying in $wait s ..." -ForegroundColor Yellow; Start-Sleep -Seconds $wait }
            try {
                if ($outFile) { Invoke-WebRequest -Uri $url -OutFile $outFile -UseBasicParsing; return }
                return (Invoke-WebRequest -Uri $url -UseBasicParsing).Content
            } catch {
                Write-Host "  Download failed: $($_.Exception.Message)" -ForegroundColor Yellow
                $last = $_
            }
        }
        throw $last
    }

    try {
        Write-Host ''
        Write-Host '  Aigoo installer' -ForegroundColor White
        $v = "$(Get-WithRetry "https://raw.githubusercontent.com/$repo/main/VERSION" $null)".Trim()
        if ($v -notmatch '^\d+(\.\d+)+$') { throw "Unexpected VERSION content: $v" }
        Write-Host "  Latest version: V$v"

        $base = "https://raw.githubusercontent.com/$repo/v$v"
        $work = Join-Path $env:TEMP ("aigoo_{0}_{1}" -f $v, (Get-Date -Format 'yyyyMMdd-HHmmss'))
        New-Item -ItemType Directory -Force -Path $work | Out-Null
        $zip = Join-Path $work "Aigoo_V$v.zip"
        Write-Host "  Downloading Aigoo_V$v.zip (no progress is shown) ..." -ForegroundColor Yellow
        Get-WithRetry "$base/Aigoo_V$v.zip" $zip
        $want = ("$(Get-WithRetry "$base/Aigoo_V$v.zip.sha256" $null)".Trim() -split '\s+')[0]
        $got = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash
        if ($got -ne $want) { throw "SHA256 mismatch for Aigoo_V$v.zip (expected $want, got $got)" }
        Write-Host '  SHA256 verified' -ForegroundColor Green

        $pkg = Join-Path $work 'pkg'
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [IO.Compression.ZipFile]::ExtractToDirectory($zip, $pkg)
        $install = Join-Path $pkg "Install_V$v.ps1"
        $payload = Join-Path $pkg 'payload.zip'
        if (-not (Test-Path -LiteralPath $install) -or -not (Test-Path -LiteralPath $payload)) { throw 'The package is incomplete' }

        & "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -File $install -Payload $payload
        $rc = $LASTEXITCODE
        Write-Host ''
        if ($rc -eq 0) {
            Write-Host '  RESULT: OK - all required checks passed.' -ForegroundColor Green
        } elseif ($rc -eq 99) {
            Write-Host '  RESULT: INSTALL STOPPED by an unexpected error - see the red lines above and the log on the Desktop.' -ForegroundColor Red
        } else {
            Write-Host "  RESULT: $rc required check(s) FAILED - see the red lines above and the log on the Desktop." -ForegroundColor Red
        }
    } catch {
        Write-Host ''
        Write-Host "  RESULT: Aigoo install FAILED: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "  Nothing was installed by this step. Report it at https://github.com/$repo/issues" -ForegroundColor Yellow
    } finally {
        if ($work) { Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue }
    }
}
