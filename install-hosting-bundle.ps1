# PowerShell script to download and install ASP.NET Core Hosting Bundle
# Run this script as Administrator

Write-Host "Checking for ASP.NET Core Hosting Bundle..." -ForegroundColor Cyan

# Check if running as Administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    exit 1
}

# Check if AspNetCoreModuleV2 is registered
$module = Get-WebGlobalModule -Name "AspNetCoreModuleV2" -ErrorAction SilentlyContinue
if ($module) {
    Write-Host "AspNetCoreModuleV2 is already registered!" -ForegroundColor Green
    Write-Host "Module Path: $($module.Image)" -ForegroundColor Gray

    # Check version
    if (Test-Path $module.Image) {
        $version = (Get-Item $module.Image).VersionInfo.FileVersion
        Write-Host "Module Version: $version" -ForegroundColor Gray
    }

    Write-Host "`nIf you're still having issues, try:" -ForegroundColor Yellow
    Write-Host "1. Run 'iisreset' in an admin command prompt" -ForegroundColor Gray
    Write-Host "2. Restart your application pool in IIS Manager" -ForegroundColor Gray
    exit 0
}

Write-Host "AspNetCoreModuleV2 is NOT registered. You need to install the ASP.NET Core Hosting Bundle." -ForegroundColor Red

# URL for .NET 8.0 Hosting Bundle
$downloadUrl = "https://download.visualstudio.microsoft.com/download/pr/751d3fcd-72db-4da2-b8d0-709c19442225/33cc492baa499dvc1c5fd8e1a7a6e6b4/dotnet-hosting-8.0.11-win.exe"
$installerPath = "$env:TEMP\dotnet-hosting-8.0-win.exe"

Write-Host "`nDownloading ASP.NET Core 8.0 Hosting Bundle..." -ForegroundColor Yellow
Write-Host "This may take a few minutes..." -ForegroundColor Gray

try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath -UseBasicParsing
    Write-Host "Download complete!" -ForegroundColor Green

    Write-Host "`nInstalling Hosting Bundle..." -ForegroundColor Yellow
    Write-Host "This will take several minutes. Please wait..." -ForegroundColor Gray

    Start-Process -FilePath $installerPath -ArgumentList "/quiet", "/norestart" -Wait -NoNewWindow

    Write-Host "`nHosting Bundle installed successfully!" -ForegroundColor Green
    Write-Host "`nRestarting IIS..." -ForegroundColor Yellow

    & iisreset

    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Installation Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "`nYour application should now work in IIS." -ForegroundColor Yellow
    Write-Host "Try accessing: http://localhost:8001/weatherforecast" -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan

    # Cleanup
    Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
}
catch {
    Write-Host "`nERROR: Failed to download or install the Hosting Bundle." -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`nPlease download and install manually from:" -ForegroundColor Yellow
    Write-Host "https://dotnet.microsoft.com/download/dotnet/8.0" -ForegroundColor Cyan
    Write-Host "Look for 'Hosting Bundle' under ASP.NET Core Runtime 8.0" -ForegroundColor Gray
    exit 1
}
