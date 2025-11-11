# PowerShell script to configure IIS for PipelinePilot
# Run this script as Administrator

param(
    [string]$SiteName = "PipelinePilot",
    [string]$AppPoolName = "PipelinePilot",
    [string]$PhysicalPath = "D:\PipelinePilot\publish",
    [int]$Port = 8001
)

Write-Host "Configuring IIS for PipelinePilot..." -ForegroundColor Cyan

# Import IIS module
Import-Module WebAdministration -ErrorAction Stop

# Check if running as Administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    exit 1
}

# Stop existing site and app pool if they exist
Write-Host "Checking for existing site and app pool..." -ForegroundColor Yellow
if (Test-Path "IIS:\Sites\$SiteName") {
    Write-Host "Stopping and removing existing site: $SiteName" -ForegroundColor Yellow
    Stop-WebSite -Name $SiteName -ErrorAction SilentlyContinue
    Remove-WebSite -Name $SiteName
}

if (Test-Path "IIS:\AppPools\$AppPoolName") {
    Write-Host "Stopping and removing existing app pool: $AppPoolName" -ForegroundColor Yellow
    Stop-WebAppPool -Name $AppPoolName -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2
    Remove-WebAppPool -Name $AppPoolName
}

# Create Application Pool
Write-Host "Creating application pool: $AppPoolName" -ForegroundColor Green
$appPool = New-WebAppPool -Name $AppPoolName
$appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value ""
$appPool | Set-ItemProperty -Name "startMode" -Value "AlwaysRunning"

Write-Host "Application Pool configured with:" -ForegroundColor Green
Write-Host "  - .NET CLR Version: No Managed Code" -ForegroundColor Gray
Write-Host "  - Start Mode: AlwaysRunning" -ForegroundColor Gray

# Create Website
Write-Host "Creating website: $SiteName" -ForegroundColor Green
$site = New-WebSite -Name $SiteName `
    -PhysicalPath $PhysicalPath `
    -ApplicationPool $AppPoolName `
    -Port $Port `
    -Force

Write-Host "Website configured with:" -ForegroundColor Green
Write-Host "  - Physical Path: $PhysicalPath" -ForegroundColor Gray
Write-Host "  - Port: $Port" -ForegroundColor Gray
Write-Host "  - Protocol: HTTP" -ForegroundColor Gray

# Set permissions for the app pool identity
Write-Host "Setting folder permissions..." -ForegroundColor Green
$acl = Get-Acl $PhysicalPath
$identity = "IIS AppPool\$AppPoolName"
$fileSystemRights = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute
$inheritanceFlags = [System.Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [System.Security.AccessControl.InheritanceFlags]::ObjectInherit
$propagationFlags = [System.Security.AccessControl.PropagationFlags]::None
$accessControlType = [System.Security.AccessControl.AccessControlType]::Allow

$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($identity, $fileSystemRights, $inheritanceFlags, $propagationFlags, $accessControlType)
$acl.SetAccessRule($accessRule)
Set-Acl -Path $PhysicalPath -AclObject $acl

Write-Host "Permissions set for: $identity" -ForegroundColor Gray

# Create logs directory if it doesn't exist
$logsPath = Join-Path $PhysicalPath "logs"
if (-not (Test-Path $logsPath)) {
    Write-Host "Creating logs directory..." -ForegroundColor Green
    New-Item -Path $logsPath -ItemType Directory -Force | Out-Null
}

# Set permissions for logs directory
$logsAcl = Get-Acl $logsPath
$logsFileSystemRights = [System.Security.AccessControl.FileSystemRights]::Modify
$logsAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($identity, $logsFileSystemRights, $inheritanceFlags, $propagationFlags, $accessControlType)
$logsAcl.SetAccessRule($logsAccessRule)
Set-Acl -Path $logsPath -AclObject $logsAcl

Write-Host "Logs directory permissions set" -ForegroundColor Gray

# Start the application pool and website
Write-Host "Starting application pool and website..." -ForegroundColor Green
Start-WebAppPool -Name $AppPoolName
Start-WebSite -Name $SiteName
Start-Sleep -Seconds 2

# Verify the site is running
$appPoolState = (Get-WebAppPoolState -Name $AppPoolName).Value
$siteState = (Get-WebsiteState -Name $SiteName).Value

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "IIS Configuration Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "App Pool Status: $appPoolState" -ForegroundColor $(if($appPoolState -eq "Started"){"Green"}else{"Red"})
Write-Host "Website Status: $siteState" -ForegroundColor $(if($siteState -eq "Started"){"Green"}else{"Red"})
Write-Host "`nYour application should now be accessible at:" -ForegroundColor Yellow
Write-Host "  http://localhost:$Port/weatherforecast" -ForegroundColor Cyan
Write-Host "`nIf you encounter issues, check the logs at:" -ForegroundColor Yellow
Write-Host "  $logsPath" -ForegroundColor Gray
Write-Host "========================================`n" -ForegroundColor Cyan
