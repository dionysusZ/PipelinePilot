# PowerShell script to open firewall for IIS website
# Run this script as Administrator

param(
    [int]$Port = 8001,
    [string]$RuleName = "PipelinePilot IIS"
)

Write-Host "Opening firewall for port $Port..." -ForegroundColor Cyan

# Check if running as Administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

# Check if rule already exists
$existingRule = Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue

if ($existingRule) {
    Write-Host "Firewall rule '$RuleName' already exists." -ForegroundColor Yellow
    Write-Host "Removing old rule and creating new one..." -ForegroundColor Yellow
    Remove-NetFirewallRule -DisplayName $RuleName
}

# Create inbound firewall rule for the port
try {
    New-NetFirewallRule -DisplayName $RuleName `
        -Direction Inbound `
        -Protocol TCP `
        -LocalPort $Port `
        -Action Allow `
        -Profile Any `
        -Enabled True | Out-Null

    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Firewall Rule Created Successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Rule Name: $RuleName" -ForegroundColor Gray
    Write-Host "Port: $Port" -ForegroundColor Gray
    Write-Host "Protocol: TCP" -ForegroundColor Gray
    Write-Host "Direction: Inbound" -ForegroundColor Gray
    Write-Host "========================================`n" -ForegroundColor Cyan

    # Get local IP addresses
    Write-Host "Your computer's IP addresses:" -ForegroundColor Yellow
    $ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -ne "127.0.0.1"} | Select-Object -ExpandProperty IPAddress

    foreach ($ip in $ipAddresses) {
        Write-Host "  http://${ip}:${Port}/weatherforecast" -ForegroundColor Cyan
    }

    Write-Host "`nYou can now access your app from your phone using one of the URLs above." -ForegroundColor Green
    Write-Host "Make sure your phone is on the same network as this computer!" -ForegroundColor Yellow
    Write-Host "========================================`n" -ForegroundColor Cyan
}
catch {
    Write-Host "`nERROR: Failed to create firewall rule." -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
