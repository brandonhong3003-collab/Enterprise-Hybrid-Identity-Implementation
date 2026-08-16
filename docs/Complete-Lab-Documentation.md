# Enterprise Hybrid Identity Implementation
**Complete Hands-On Infrastructure & Engineering Log (Week 1 – Week 4)**  
**Author:** Systems Administrator | **On-Prem Domain:** `labops.local` | **Cloud Tenant:** `labopssyd.onmicrosoft.com`

---

## Executive Summary & Environment Specification
This technical implementation document tracks the end-to-end setup, troubleshooting, and verification of an enterprise-grade Hybrid Identity Architecture. Over four weeks of implementation, a local Active Directory Domain Services (AD DS) environment was designed, bridged to Microsoft Entra ID via Entra Connect Sync, and expanded into cloud device management using Microsoft Intune.

| Resource Name | Role / Function | Operating System | Network Configuration |
| :--- | :--- | :--- | :--- |
| **DC01** | Domain Controller, DNS, Entra Connect Sync Host | Windows Server 2022 | Dual-NIC: `192.168.1.10` (Internal) + NAT (Internet) |
| **CLIENT11** | Workstation Endpoint | Windows 11 Pro | Single NIC: `192.168.1.20` (DNS: `192.168.1.10`) |
| **Entra Tenant** | Cloud Identity & MDM Service | Microsoft Entra ID / Intune | Primary Domain: `labopssyd.onmicrosoft.com` |

---

## Week 1: Foundation & Cloud Identity
* **Virtualization Environment:** Configured VirtualBox hypervisor settings and created isolated virtual networks (`LabNetwork`) housing `DC01` and `CLIENT11`.
* **Cloud Tenant Provisioning:** Established Microsoft Entra ID tenant `labopssyd.onmicrosoft.com` and administrative identities.
* **On-Prem Server Build (DC01):** Promoted Windows Server 2022 to Domain Controller for `labops.local` (`192.168.1.10`).
* **Organizational Units:** Designed `LabOps-Objects > Users / Workstations` for lifecycle governance[cite: 1].

---

## Week 2: Admin Roles, Sync Bridge & Hybrid Join
* **Entra Connect Engine Setup:** Executed `AzureADConnect.msi` on `DC01` using dedicated `sync-admin` identity[cite: 1].
* **Troubleshooting Scenarios Resolved:**
  * *IE ESC Script Error:* Disabled IE ESC on Server 2022 to clear script execution blocks during setup wizard execution[cite: 1].
  * *Non-Routable `.local` UPN Warning:* Configured explicitly to proceed with default tenant UPN mapping[cite: 1].
  * *Dual-NIC Routing:* Configured Adapter 1 (Internal) for local AD/DNS and Adapter 2 (NAT) for outward Microsoft cloud sync endpoints[cite: 1].
* **Group Policy Lockout Scoping Realignment:** 
  * *Issue:* Lockout policies linked to sub-OUs only apply to local SAM accounts, leaving AD domain accounts unaffected[cite: 1].
  * *Resolution:* Relinked lockout policy (5 attempts, 15 min duration) to the Domain Root in Default Domain Policy[cite: 1].

---

## Week 3: Cloud Tenant Setup & Intune MDM Management
* **MDM Onboarding:** Configured automatic Intune registration and onboarded `CLIENT11`[cite: 1].
* **Compliance & Security Baselines:**
  * Built custom Settings Catalog profile (`WIN11-Security-Customizations`) blocking removable storage access (`E:\ is not accessible`)[cite: 1].
  * Configured BitLocker, Firewall, and Antivirus compliance monitoring[cite: 1].
* **Application Packaging:** Deployed M365 Apps Suite and Company Portal via native Intune Store integrations[cite: 1].

---

## Week 4: Automation & Proactive Remediations
* **Platform Script Execution:** Deployed custom PowerShell directory creation script via IME (`C:\LabOps_Automation\IntuneScript_Log.txt`)[cite: 1].
* **Proactive Remediation Drift Control:**
  * Authored paired detection (`Exit 0`/`Exit 1`) and remediation scripts in 64-bit PowerShell host[cite: 1].
  * Verified self-healing registry enforcement at `HKLM:\SOFTWARE\LabOps` with `ComplianceCheck = 1`[cite: 1].
