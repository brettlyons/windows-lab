# Notes: Windows AD Lab

## Research & References

### Active Directory Setup
- (To be filled during setup)

### Group Policy Objects
- (To be filled during GPO configuration)

## Commands & Procedures

### AD DS Installation (PowerShell)
```powershell
# Install AD DS role
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Promote to Domain Controller
Install-ADDSForest -DomainName "yourdomain.local" -DomainNetbiosName "YOURDOMAIN" -InstallDns
```

### Join Computer to Domain (PowerShell)
```powershell
Add-Computer -DomainName "yourdomain.local" -Credential (Get-Credential) -Restart
```

### Useful GPO Commands
```powershell
# List all GPOs
Get-GPO -All

# Create new GPO
New-GPO -Name "GPO Name"

# Link GPO to OU
New-GPLink -Name "GPO Name" -Target "OU=Computers,DC=yourdomain,DC=local"

# Force GPO update on client
gpupdate /force

# View applied GPOs
gpresult /r
```

## Findings
- (To be updated as lab progresses)

## Troubleshooting Log
- (To be updated as issues arise)
