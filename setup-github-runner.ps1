# PowerShell script to setup GitHub Actions Self-Hosted Runner
# Run this script as Administrator

param(
    [Parameter(Mandatory=$true)]
    [string]$Token,
    [string]$RunnerName = "$env:COMPUTERNAME-runner",
    [string]$RunnerFolder = "C:\actions-runner",
    [string]$GitHubRepo = "https://github.com/dionysusZ/PipelinePilot"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GitHub Actions Runner Setup" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if running as Administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

# Create runner directory
if (-not (Test-Path $RunnerFolder)) {
    Write-Host "Creating runner folder: $RunnerFolder" -ForegroundColor Yellow
    New-Item -Path $RunnerFolder -ItemType Directory -Force | Out-Null
} else {
    Write-Host "Runner folder already exists: $RunnerFolder" -ForegroundColor Yellow
}

# Download latest runner
Write-Host "`nDownloading GitHub Actions Runner..." -ForegroundColor Yellow
$latestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/actions/runner/releases/latest"
$asset = $latestRelease.assets | Where-Object { $_.name -like "*win-x64-*.zip" } | Select-Object -First 1

if (-not $asset) {
    Write-Host "ERROR: Could not find Windows runner package" -ForegroundColor Red
    exit 1
}

$downloadUrl = $asset.browser_download_url
$zipFile = Join-Path $RunnerFolder $asset.name

Write-Host "Downloading from: $downloadUrl" -ForegroundColor Gray

try {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile -UseBasicParsing
    Write-Host "Download complete!" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to download runner" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Extract runner
Write-Host "`nExtracting runner..." -ForegroundColor Yellow
try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipFile, $RunnerFolder)
    Write-Host "Extraction complete!" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to extract runner" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

# Clean up zip file
Remove-Item $zipFile -Force

# Configure runner
Write-Host "`nConfiguring runner..." -ForegroundColor Yellow
Write-Host "Repository: $GitHubRepo" -ForegroundColor Gray
Write-Host "Runner Name: $RunnerName" -ForegroundColor Gray

cd $RunnerFolder

try {
    $configCmd = ".\config.cmd --url $GitHubRepo --token $Token --name $RunnerName --work _work --runasservice --windowslogonaccount 'NT AUTHORITY\SYSTEM'"
    Invoke-Expression $configCmd

    Write-Host "`nRunner configured successfully!" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to configure runner" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host "`nPlease run the configuration manually:" -ForegroundColor Yellow
    Write-Host "cd $RunnerFolder" -ForegroundColor Cyan
    Write-Host ".\config.cmd --url $GitHubRepo --token YOUR_TOKEN" -ForegroundColor Cyan
    exit 1
}

# Install and start service
Write-Host "`nInstalling runner as Windows service..." -ForegroundColor Yellow

try {
    .\svc.cmd install
    Write-Host "Service installed!" -ForegroundColor Green

    Write-Host "`nStarting runner service..." -ForegroundColor Yellow
    .\svc.cmd start

    Start-Sleep -Seconds 2

    $status = .\svc.cmd status
    Write-Host "Service Status: $status" -ForegroundColor Gray

} catch {
    Write-Host "ERROR: Failed to install/start service" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    exit 1
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nYour self-hosted runner is now active!" -ForegroundColor Yellow
Write-Host "`nNext steps:" -ForegroundColor Yellow
Write-Host "1. Verify the runner appears in GitHub:" -ForegroundColor Gray
Write-Host "   $GitHubRepo/settings/actions/runners" -ForegroundColor Cyan
Write-Host "2. Push code to trigger the deployment workflow" -ForegroundColor Gray
Write-Host "3. Monitor the Actions tab on GitHub" -ForegroundColor Gray
Write-Host "`nRunner service commands:" -ForegroundColor Yellow
Write-Host "  Status:  .\svc.cmd status" -ForegroundColor Gray
Write-Host "  Stop:    .\svc.cmd stop" -ForegroundColor Gray
Write-Host "  Start:   .\svc.cmd start" -ForegroundColor Gray
Write-Host "========================================`n" -ForegroundColor Cyan
