# Notes: Windows AD Lab

## Research & References

### Active Directory Setup
- (To be filled during setup)

### Group Policy Objects
- (To be filled during GPO configuration)

## Commands & Procedures

### Proxmox VM Creation

```bash
# Clone Server 2019 template (109) to create DC01
qm clone 109 120 --name DC01 --full 1 --storage vm-disks

# Update DC01 description
qm set 120 --name DC01 --description 'Windows Server 2019 Domain Controller for home.lab'

# Create CLIENT01 (Win11 with UEFI/Secure Boot/TPM)
qm create 121 --name CLIENT01 \
  --memory 4096 --cores 2 --cpu host \
  --ostype win11 --machine q35 --bios ovmf \
  --net0 virtio,bridge=vmbr0 \
  --scsihw virtio-scsi-single \
  --efidisk0 vm-disks:1,efitype=4m,pre-enrolled-keys=1 \
  --tpmstate0 vm-disks:1,version=v2.0 \
  --scsi0 vm-disks:50,discard=on,ssd=1 \
  --boot order=scsi0 \
  --agent 1

# Create CLIENT02 (same as CLIENT01)
qm create 122 --name CLIENT02 \
  --memory 4096 --cores 2 --cpu host \
  --ostype win11 --machine q35 --bios ovmf \
  --net0 virtio,bridge=vmbr0 \
  --scsihw virtio-scsi-single \
  --efidisk0 vm-disks:1,efitype=4m,pre-enrolled-keys=1 \
  --tpmstate0 vm-disks:1,version=v2.0 \
  --scsi0 vm-disks:50,discard=on,ssd=1 \
  --boot order=scsi0 \
  --agent 1

# Attach Win11 ISO and VirtIO drivers to client VMs
qm set 121 --ide2 local:iso/Win11_unattended.iso,media=cdrom --ide0 local:iso/virtio-win.iso,media=cdrom
qm set 122 --ide2 local:iso/Win11_unattended.iso,media=cdrom --ide0 local:iso/virtio-win.iso,media=cdrom

# Start VMs
qm start 120  # DC01
qm start 121  # CLIENT01
qm start 122  # CLIENT02

# List lab VMs
pvesh get /cluster/resources --type vm | grep -E "120|121|122"
```

### AD DS Installation (PowerShell on DC01)
```powershell
# Install AD DS role
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# Promote to Domain Controller (prompts for DSRM password)
Install-ADDSForest -DomainName home.lab

# Configure DNS forwarder after reboot
Add-DnsServerForwarder -IPAddress 172.16.1.8
```

**Status:** DC01 promoted to domain controller for home.lab on 2026-01-30. QEMU guest agent installed.

### Join Computer to Domain (PowerShell on Clients)
```powershell
# Set DNS to point to DC01
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 172.16.1.10

# Join domain
Add-Computer -DomainName "home.lab" -Credential (Get-Credential) -Restart
```

### Useful GPO Commands
```powershell
# List all GPOs
Get-GPO -All

# Create new GPO
New-GPO -Name "GPO Name"

# Link GPO to OU
New-GPLink -Name "GPO Name" -Target "OU=Computers,DC=home,DC=lab"

# Force GPO update on client
gpupdate /force

# View applied GPOs
gpresult /r
```

## Findings
- DHCP reservations configured for all lab VMs:
  - DC01: 172.16.1.10 (BC:24:11:20:19:82)
  - CLIENT01: 172.16.1.11 (BC:24:11:F0:57:55)
  - CLIENT02: 172.16.1.12 (BC:24:11:15:1F:81)
- Windows firewall may block ICMP ping by default
- Win11 unattended ISO and VirtIO drivers attached to CLIENT01/CLIENT02
  - Boot order set to IDE2 (Win11 ISO) first
  - Local admin after install: SetupAdmin / TempPass123!

### QEMU Guest Agent Installation
The virtio-win ISO includes the QEMU guest agent. On each Windows VM:

```powershell
# If virtio-win ISO is mounted as D:
D:\guest-agent\qemu-ga-x86_64.msi /quiet

# Or use the full virtio installer (includes drivers + agent)
D:\virtio-win-gt-x64.msi /quiet
```

Alternatively via GUI: Open the virtio-win CD → run `virtio-win-gt-x64.msi`

After install, the `QEMU Guest Agent` service should be running.

## Troubleshooting Log

### Windows 11 "This PC doesn't meet requirements" (2026-02-04)
**Problem:** CLIENT01/CLIENT02 stuck at "This PC doesn't meet Windows 11 requirements" screen.

**Cause:** Missing TPM 2.0. Windows 11 requires TPM even in VMs.

**Fix:** Add virtual TPM to each VM:
```bash
# Stop VMs first
qm stop 121 && qm stop 122

# Add TPM 2.0
qm set 121 --tpmstate0 vm-disks:1,version=v2.0
qm set 122 --tpmstate0 vm-disks:1,version=v2.0

# Start VMs
qm start 121 && qm start 122
```

**Prevention:** Include `--tpmstate0` in VM creation command for Win11 VMs.

### Windows can't find hard disk during install (2026-02-04)
**Problem:** Windows installer doesn't see the VirtIO SCSI disk.

**Cause:** Windows doesn't include VirtIO drivers out of the box.

**Fix:** At "Where do you want to install Windows?" screen:
1. Click "Load driver" → "Browse"
2. Navigate to virtio-win CD (D: or E:)
3. Select `amd64\w11` folder
4. Click OK, select driver, click Next

### Windows install loops back to disk selection (2026-02-04)
**Problem:** After copying files, VM reboots and returns to "Where do you want to install?" screen.

**Cause:** Boot order has ISO (ide2) before disk (scsi0).

**Fix:**
```bash
qm set 121 --boot order=scsi0
qm set 122 --boot order=scsi0
```
VM will boot from disk on next reboot.
