$ErrorActionPreference = "Stop"

$url = "https://github.com/dytescn/dytes/releases/latest/download/dytes-windows.exe"
$installDir = Join-Path $env:LOCALAPPDATA "dytes\bin"
$target = Join-Path $installDir "dytes.exe"

New-Item -ItemType Directory -Force -Path $installDir | Out-Null
Write-Host "Downloading dytes..."
Invoke-WebRequest -Uri $url -OutFile $target

$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$installDir*") {
    [Environment]::SetEnvironmentVariable("Path", "$userPath;$installDir", "User")
    Write-Host "Added $installDir to user PATH. Restart your terminal."
}

Write-Host "Installed: $target"
Write-Host "Run: dytes --version"
