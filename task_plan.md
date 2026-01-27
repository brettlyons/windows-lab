# Task Plan: Windows AD Lab Setup

## Goal
Build a 3-VM Windows lab environment with Active Directory and Group Policy for hands-on learning and documentation.

## Phases
- [ ] Phase 1: Plan infrastructure and VM specifications
- [ ] Phase 2: Create and configure Domain Controller VM
- [ ] Phase 3: Create and join client VMs to domain
- [ ] Phase 4: Configure Group Policy Objects (GPOs)
- [ ] Phase 5: Test and document the environment

## Infrastructure Overview

### VM Specifications (Planned)
| VM Name | Role | OS | RAM | Storage | IP |
|---------|------|----|----|---------|-----|
| DC01 | Domain Controller | Windows Server 2022 | 4GB | 60GB | TBD |
| CLIENT01 | Domain Client | Windows 10/11 | 4GB | 50GB | TBD |
| CLIENT02 | Domain Client | Windows 10/11 | 4GB | 50GB | TBD |

### Network Design
- Domain Name: TBD
- Network Subnet: TBD
- DNS: DC01 will serve as primary DNS

## Questions to Answer Before Starting

Fill these in before beginning the lab:

### 1. Hypervisor
**Options:** VirtualBox, VMware Workstation, Hyper-V, Proxmox, libvirt/KVM
**Your choice:** _____________

### 2. Windows Server Version
**Options:** Server 2019, Server 2022, Evaluation ISO (free 180 days)
**Your choice:** _____________

### 3. Client OS Version
**Options:** Windows 10, Windows 11, Evaluation ISO
**Your choice:** _____________

### 4. Domain Name
**Examples:** lab.local, homelab.internal, yourname.local
**Your choice:** _____________

### 5. Network Configuration
**Options:**
- **NAT** - VMs share host's internet, isolated from LAN
- **Bridged** - VMs get IPs on your home network
- **Internal/Host-only** - VMs only talk to each other and host
**Your choice:** _____________

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

## Decisions Made
- (Will be filled after answering questions above)

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
**Currently in Phase 1** - Awaiting user input on infrastructure decisions
