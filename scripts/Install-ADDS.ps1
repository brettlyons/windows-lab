# Install-ADDS.ps1
# Run on DC01 to install Active Directory Domain Services and promote to Domain Controller
# Domain: home.lab

#Requires -RunAsAdministrator

param(
    [string]$DomainName = "home.lab",
    [string]$NetBIOSName = "HOME",
    [string]$DNSForwarder = "172.16.1.8",
    [switch]$SkipNetworkConfig
)

$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "AD DS Installation Script for $DomainName" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Verify network configuration
Write-Host "[1/5] Checking network configuration..." -ForegroundColor Yellow
$adapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
$ipConfig = Get-NetIPAddress -InterfaceIndex $adapter.InterfaceIndex -AddressFamily IPv4

Write-Host "  Adapter: $($adapter.Name)"
Write-Host "  IP Address: $($ipConfig.IPAddress)"

if ($ipConfig.IPAddress -ne "172.16.1.10") {
    Write-Host "  WARNING: Expected IP 172.16.1.10, got $($ipConfig.IPAddress)" -ForegroundColor Yellow
    Write-Host "  Proceeding anyway (DHCP reservation should handle this)" -ForegroundColor Yellow
}

# Step 2: Install AD DS Role
Write-Host ""
Write-Host "[2/5] Installing AD DS Role..." -ForegroundColor Yellow
$addsFeature = Get-WindowsFeature -Name AD-Domain-Services

if ($addsFeature.Installed) {
    Write-Host "  AD DS Role already installed" -ForegroundColor Green
} else {
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
    Write-Host "  AD DS Role installed successfully" -ForegroundColor Green
}

# Step 3: Prompt for Safe Mode password
Write-Host ""
Write-Host "[3/5] Domain Controller Promotion Setup" -ForegroundColor Yellow
Write-Host "  Domain: $DomainName"
Write-Host "  NetBIOS: $NetBIOSName"
Write-Host ""

$safeModePassword = Read-Host -AsSecureString -Prompt "Enter Directory Services Restore Mode (DSRM) password"

# Step 4: Promote to Domain Controller
Write-Host ""
Write-Host "[4/5] Promoting to Domain Controller..." -ForegroundColor Yellow
Write-Host "  This will restart the server automatically." -ForegroundColor Yellow
Write-Host ""

$params = @{
    DomainName                    = $DomainName
    DomainNetbiosName             = $NetBIOSName
    SafeModeAdministratorPassword = $safeModePassword
    InstallDns                    = $true
    CreateDnsDelegation           = $false
    DatabasePath                  = "C:\Windows\NTDS"
    LogPath                       = "C:\Windows\NTDS"
    SysvolPath                    = "C:\Windows\SYSVOL"
    NoRebootOnCompletion          = $false
    Force                         = $true
}

Install-ADDSForest @params

# Note: Server will reboot here. Step 5 runs after reboot via scheduled task or manual execution.
