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

### 3. Time Skew & OAuth Token Renewal Failure
* **Issue:** `CLIENT11` failed automatic MDM enrollment with `Access is denied (0x80070005)` and Event ID 76 (`Current time is earlier than expected renew attempt time`).
* **Root Cause:** `DC01` system clock drifted into the future, causing Entra ID to issue future-dated OAuth tokens (May 2027) that `CLIENT11` rejected during local validation.
* **Resolution:** Configured `DC01` time hierarchy via `w32tm /config /syncfromflags:manual`, resynced `CLIENT11` clock, and purged stale enrollment GUIDs under `HKLM\SOFTWARE\Microsoft\Enrollments`.

### 4. MDM Auto-Discovery Endpoint Bypass
* **Issue:** User-context enrollment thrown from `deviceenroller.exe` failed due to missing CNAME DNS auto-discovery for `labopssyd.onmicrosoft.com`.
* **Root Cause:** Tenant MDM discovery endpoints were unmapped in Entra ID Mobility settings during initial setup.
* **Resolution:** Hardcoded the direct Intune discovery endpoint (`https://enrollment.manage.microsoft.com/enrollmentserver/discovery.svc`) in Windows Access Work or School settings, successfully acquiring PRT SSO and establishing Intune Compliance.

### 5. Risk-Based Conditional Access Policy (Entra ID P2)
* **Issue/Requirement:** Basic authentication allows access from unmanaged or compromised contexts without dynamic risk evaluation.
* **Root Cause:** Default security configurations enforce generic MFA prompts but lack granular sign-in risk evaluation and device compliance enforcement.
* **Resolution:** Disabled Security Defaults and deployed policy `CA001: Risk-Based Sign-in Control (Medium/High Risk)`, forcing MFA or Intune Device Compliance whenever medium or high sign-in risk is detected.
### 6. Privileged Identity Management (PIM) & Zero Standing Access
* **Issue/Requirement:** Permanent administrative rights (standing privileges) increase vulnerability to credential theft and lateral movement.
* **Root Cause:** Standard role assignments grant 24/7 administrative access regardless of whether active maintenance is being performed.
* **Resolution:** Reconfigured administrative roles to **Eligible** assignments in Entra PIM. Enforced Just-In-Time (JIT) role elevation requiring explicit business justification, step-up MFA, and automated time-bound session revocation.
#### 7. Custom Intune Compliance Baseline Deployment
* **Issue/Requirement:** Unpatched or unencrypted endpoints pose a risk when connecting to corporate applications without health validation.
* **Root Cause:** Default MDM enrollment checks device registry status but does not evaluate active Firewall state, Antivirus health, or OS version thresholds.
* **Resolution:** Authored and deployed `WIN11-Compliance-Baseline` via Microsoft Intune, enforcing BitLocker encryption, Microsoft Defender status, and a minimum OS build of 10.0.22631 across targeted endpoints.
#### 8. Endpoint Security & Defender Antivirus Baseline
* **Issue/Requirement:** Unmanaged antivirus settings on endpoints can leave devices vulnerable to zero-day threats if end users disable local protection.
* **Root Cause:** Standard Windows Defender installations allow local user overrides if not governed by central MDM policy controls.
* **Resolution:** Configured and deployed `WIN11-Defender-ASR-Baseline` via Intune Endpoint Security, enforcing Real-Time Behavior Monitoring, Cloud Protection, and Intrusion Prevention across managed workloads.
#### 9. Automated App Delivery via Microsoft Intune
* **Issue/Requirement:** Manual software installation on newly onboarded devices increases IT overhead and leads to inconsistent software baselines.
* **Root Cause:** Endpoints lack automated software provisioning post-domain join without central MDM app management.
* **Resolution:** Configured enterprise application deployment via Microsoft Intune (Microsoft Store integration), assigning the Company Portal infrastructure app with a Required install intent across managed devices.
#### 10. End-to-End Policy Sync & Compliance Verification
* **Issue/Requirement:** Validate that cloud-configured identity, compliance, security, and app policies propagate and execute on local endpoints.
* **Root Cause:** Policy settings in Intune can remain in a pending state until an MDM check-in cycle occurs or client-side sync is executed.
* **Resolution:** Performed manual and remote MDM policy synchronization on `CLIENT11-VM`. Confirmed active engine telemetry as Intune dynamically audited the endpoint, marking BitLocker non-compliant as expected due to lab VM encryption baselines.











---

## 📂 Project Documentation

* [Full Engineering Execution Log (Week 1 – Week 4)](docs/Complete-Lab-Documentation.md)
* [Architecture Diagram](docs/Architecture-Diagram.png)
* [PowerShell Scripts & Remediations](scripts/)
* [Hybrid Identity Verification](docs/screenshots/Hybrid-Join-dsregcmd.png)
* [Account Integration View](docs/screenshots/Hybrid-Join-dsregcmd-account.png)
* [Microsoft Intune Compliance Status](docs/screenshots/Intune-Compliance-Success.png)
* [Risk-Based Conditional Access Policy](docs/screenshots/CA001-Risk-Policy.png)
* [PIM Active Assignment Proof](docs/screenshots/PIM-Active-Assignment.png)
* [Intune Compliance Policy Baseline](docs/screenshots/Intune-Compliance-Policy-Baseline.png)
* [Intune Defender Security Policy](docs/screenshots/Intune-Defender-Security-Policy.png)
* [Intune App Deployment Baseline](docs/screenshots/Intune-App-Deployment.png)
* [Intune Policy Sync Verification](docs/screenshots/Intune-End-to-End-Policy-Sync.png)
