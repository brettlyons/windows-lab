# Task Plan: Windows AD Lab Setup

## Goal
Build a 3-VM Windows lab environment with Active Directory and Group Policy for hands-on learning and documentation.

## Phases
- [x] Phase 1: Plan infrastructure and VM specifications
- [x] Phase 2: Create and configure Domain Controller VM
- [ ] Phase 3: Create and join client VMs to domain
- [ ] Phase 4: Configure Group Policy Objects (GPOs)
- [ ] Phase 5: Test and document the environment

## Infrastructure Overview

### VM Specifications
| VM Name | VMID | Role | OS | RAM | Storage | IP | Status |
|---------|------|------|----|----|---------|-----|--------|
| DC01 | 120 | Domain Controller | Windows Server 2019 | 4GB | 40GB | 172.16.1.10 | Running |
| CLIENT01 | 121 | Domain Client | Windows 11 Pro | 4GB | 50GB | DHCP | Created |
| CLIENT02 | 122 | Domain Client | Windows 11 Pro | 4GB | 50GB | DHCP | Created |

**Proxmox Cluster:** smallbox-0,1,2 (VMs on smallbox-0)
**Win11 ISO:** `/home/blyons/intune-lab/Win11_unattended.iso` (autounattend with SetupAdmin/TempPass123!)

### Network Design
- Domain Name: home.lab
- Network Subnet: 172.16.1.0/24 (bridged to home network)
- Gateway: 172.16.1.1 (assumed - confirm your router)
- DNS: DC01 (172.16.1.10) as primary for domain; forwards to 172.16.1.8

## Questions to Answer Before Starting

Fill these in before beginning the lab:

### 1. Hypervisor
**Options:** VirtualBox, VMware Workstation, Hyper-V, Proxmox, libvirt/KVM
**Your choice:** KVM / Proxmox

### 2. Windows Server Version
**Options:** Server 2019, Server 2022, Evaluation ISO (free 180 days)
**Your choice:** Windows Server 2019

### 3. Client OS Version
**Options:** Windows 10, Windows 11, Evaluation ISO
**Your choice:** Windows 11 Pro (deployment ISO automation in separate repo)

### 4. Domain Name
**Examples:** lab.local, homelab.internal, yourname.local
**Your choice:** home.lab

### 5. Network Configuration
**Options:**
- **NAT** - VMs share host's internet, isolated from LAN
- **Bridged** - VMs get IPs on your home network
- **Internal/Host-only** - VMs only talk to each other and host
**Your choice:** Bridged - VMs will get IPs on home network (172.16.1.x)

### 6. GPO Focus Areas
**Pick which to prioritize (or all):**
- [ ] Password & account lockout policies
- [ ] Software restriction / AppLocker
- [ ] Drive mappings & folder redirection
- [ ] Desktop branding (wallpaper, lock screen)
- [ ] Windows Update policies (WSUS simulation)
- [ ] Security settings & audit policies
- [ ] User rights assignments
- [ ] Other: _____________
**Priority:** All - comprehensive coverage of all GPO areas

## Decisions Made
- Hypervisor: KVM / Proxmox
- Server OS: Windows Server 2019
- Client OS: Windows 11 Pro (automated deployment ISO exists in separate repo)
- Domain: home.lab
- DNS server: 172.16.1.8 (homelab DNS); DC01 will also run AD-integrated DNS
- Network type: Bridged (172.16.1.x subnet)
- GPO priorities: All areas - comprehensive learning

## GPO Learning Goals
- [ ] Password policies
- [ ] Account lockout policies
- [ ] Software restriction policies
- [ ] Drive mappings
- [ ] Desktop wallpaper/branding
- [ ] Windows Update policies
- [ ] Security settings
- [ ] User rights assignments

## Errors Encountered
- (None yet)

## Status
**Currently in Phase 3** - DC01 promoted to domain controller. Awaiting client Windows installs.

### Completed
- DC01 promoted to domain controller for home.lab
- DNS forwarder configured (172.16.1.8)
- CLIENT01/CLIENT02 started, Windows 11 installing

### Immediate Next Steps
1. **Run `Install-ADDS.ps1` on DC01** - The script is ready in `scripts/Install-ADDS.ps1`
   - Connect to DC01 via RDP or console (IP: 172.16.1.10 or via DHCP reservation)
   - Copy script to DC01 and run as Administrator
   - Enter DSRM password when prompted
   - Server will reboot automatically after promotion

2. **After DC01 reboot - Configure DNS forwarder**
   ```powershell
   Add-DnsServerForwarder -IPAddress 172.16.1.8
   ```

3. **Start CLIENT01 and CLIENT02**
   - ISOs already attached (Win11_unattended.iso + virtio-win.iso)
   - Boot from IDE2 (Win11 ISO)
   - Auto-install will create local admin: SetupAdmin / TempPass123!

4. **Join clients to domain**
   ```powershell
   Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 172.16.1.10
   Add-Computer -DomainName "home.lab" -Credential (Get-Credential) -Restart
   ```

### Verification
Run `./scripts/verify-lab.sh --full` to test:
- VM status on Proxmox
- Network connectivity to DC01
- AD ports (DNS/Kerberos/LDAP/SMB)
- DNS resolution for home.lab
