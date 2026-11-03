$ErrorActionPreference = "Stop"

$base = if ($env:DYTES_DOWNLOAD_BASE) { $env:DYTES_DOWNLOAD_BASE.TrimEnd('/') } else { "https://packages.funxdata.com/core/dytes" }
$url = "$base/latest/windows/dytes.exe"
$installDir = if ($env:DYTES_INSTALL_DIR) { $env:DYTES_INSTALL_DIR } else { Join-Path $env:LOCALAPPDATA "dytes\bin" }
$target = Join-Path $installDir "dytes.exe"
$tmp = "$target.download"
$checksum = "$target.download.sha256"

New-Item -ItemType Directory -Force -Path $installDir | Out-Null

try {
    Write-Host "Downloading dytes for windows from packages.funxdata.com..."
    $downloaded = $false
    for ($attempt = 1; $attempt -le 3; $attempt++) {
        try {
            Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing
            $downloaded = $true
            break
        } catch {
            Write-Warning "Download failed (attempt $attempt/3): $($_.Exception.Message)"
            if ($attempt -lt 3) { Start-Sleep -Seconds 2 }
        }
    }
    if (-not $downloaded) {
        throw "download failed after 3 attempts: $url"
    }

    $checksumAvailable = $false
    try {
        Invoke-WebRequest -Uri "$url.sha256" -OutFile $checksum -UseBasicParsing
        $checksumAvailable = $true
    } catch {
        Write-Warning "Checksum unavailable, skipping verification: $($_.Exception.Message)"
    }
    if ($checksumAvailable) {
        $expected = ((Get-Content $checksum -TotalCount 1) -split '\s+')[0].ToLower()
        $actual = (Get-FileHash -Path $tmp -Algorithm SHA256).Hash.ToLower()
        if ($expected -and $expected -ne $actual) {
            throw "SHA-256 mismatch (expected $expected, got $actual)"
        }
        Write-Host "SHA-256 verified"
    }

    Move-Item -Force -Path $tmp -Destination $target
} finally {
    if (Test-Path $tmp) { Remove-Item $tmp -Force }
    if (Test-Path $checksum) { Remove-Item $checksum -Force }
}

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$installDir", "User")
    Write-Host "Added $installDir to user PATH. Restart your terminal."
}

Write-Host "Installed: $target"
Write-Host "Run: dytes --version"
