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

## Key Questions
1. Which hypervisor to use? (Hyper-V, VirtualBox, VMware, Proxmox, etc.)
2. Windows Server version? (2019, 2022, Evaluation?)
3. Client OS version? (Windows 10, 11, Evaluation?)
4. Domain name to use?
5. Network configuration (NAT, bridged, internal?)
6. Specific GPOs to implement and document?

## Decisions Made
- [Pending user input on infrastructure choices]

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
