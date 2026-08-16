# Enterprise Hybrid Identity & Cloud Management Infrastructure

A fully functional, enterprise-grade Hybrid Identity and Endpoint Management laboratory built from scratch. This project demonstrates the design, deployment, security hardening, and proactive remediation of a hybrid Active Directory and Microsoft Entra ID / Intune environment.

---

## 📐 Network & Architecture Topology
              +--------------------------------------------------+
              |         Microsoft Entra ID / Intune Tenant       |
              |            (labopssyd.onmicrosoft.com)           |
              +------------------------+-------------------------+
                                       ^
                                       |  (Entra Connect Sync / PHS)
                                       v
      +------------------------------------------+------------------------------------------+
      |  Internal Hypervisor Network (192.168.1.0/24)                                       |
      |                                                                                     |
      |   +------------------------------------+          +-----------------------------+   |
      |   | DC01 (Windows Server 2022)         |          | CLIENT11 (Windows 11 Pro)   |   |
      |   | • Domain Controller: labops.local  |          | • Hybrid Entra ID Joined    |   |
      |   | • DNS: 192.168.1.10                | <======> | • Intune MDM Enrolled       |   |
      |   | • Dual-NIC (Internal + NAT)        |          | • IP: 192.168.1.20          |   |
      |   | • Entra Connect Sync Engine        |          |                             |   |
      |   +------------------------------------+          +-----------------------------+   |
      +-------------------------------------------------------------------------------------+

---

## 🌟 Key Technical Highlights & Architecture

* **Hybrid Identity Bridge:** Synchronized Active Directory Domain Services (`labops.local`) to Microsoft Entra ID using **Entra Connect Sync** with Password Hash Sync (PHS).
* **Dual-NIC Domain Controller Routing:** Configured a isolated internal network adapter for AD/DNS traffic alongside a NAT adapter for outward Microsoft Cloud endpoints.
* **Cloud Endpoint Management:** Fully onboarded Windows 11 endpoints via **Microsoft Intune**, enforcing compliance policies, custom Settings Catalog configurations (BitLocker, USB blocks), and M365 App deployments.
* **Proactive Remediation & Self-Healing:** Authored custom PowerShell detection and remediation scripts running via native 64-bit Intune Management Extension (IME) to automatically fix endpoint configuration drift.
* **Security Hardening & GPOs:** Implemented domain-wide account lockout baselines, elevated user access controls, and custom logon banners.

---

## 🛠️ Key Troubleshooting & Engineering Logs

### 1. Account Lockout Policy Scoping Realignment
* **Issue:** Account lockout rules applied to a sub-OU GPO failed to lock out domain accounts after 5 invalid attempts.
* **Root Cause:** Domain-wide password/lockout rules for AD domain accounts are evaluated globally and must be linked at the Domain Root (Default Domain Policy)[cite: 1].
* **Resolution:** Relinked lockout policy to the domain root, executed `gpupdate /force`, and verified successful lockouts[cite: 1].

### 2. Proactive Remediation Registry Redirection (WOW6432Node)
* **Issue:** Script written to target `HKLM:\SOFTWARE\LabOps` was placing keys under `WOW6432Node`[cite: 1].
* **Root Cause:** IME defaults to a 32-bit PowerShell host, triggering Windows Registry Redirection[cite: 1].
* **Resolution:** Enforced **"Run script in 64-bit PowerShell Host = Yes"** in Intune[cite: 1].

---

## 📂 Project Documentation

* [Full Engineering Execution Log (Week 1 – Week 4)](docs/Complete-Lab-Documentation.md)[cite: 1]
* [PowerShell Scripts & Remediations](scripts/)[cite: 1]
