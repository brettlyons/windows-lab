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
| DC01 | Domain Controller | Windows Server 2019 | 4GB | 60GB | TBD |
| CLIENT01 | Domain Client | Windows 11 Pro | 4GB | 50GB | TBD |
| CLIENT02 | Domain Client | Windows 11 Pro | 4GB | 50GB | TBD |

### Network Design
- Domain Name: home.lab
- Network Subnet: TBD
- DNS: Existing homelab DNS at 172.16.1.8 (to be confirmed); DC01 will also serve as AD-integrated DNS

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
**Your choice:** TBD

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
**Priority:** TBD - will decide during Phase 4

## Decisions Made
- Hypervisor: KVM / Proxmox
- Server OS: Windows Server 2019
- Client OS: Windows 11 Pro (automated deployment ISO exists in separate repo)
- Domain: home.lab
- DNS server: likely 172.16.1.8 (needs confirmation)
- Network type: TBD
- GPO priorities: TBD

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
