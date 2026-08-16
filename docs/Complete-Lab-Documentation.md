Enterprise Hybrid Identity Implementation
Complete Hands-On Infrastructure & Engineering Log (Week 1 – Week 4)
Author: Systems Administrator | On-Prem Domain: labops.local | Cloud Tenant: labopssyd.onmicrosoft.com
Executive Summary & Environment Specification
This technical implementation document tracks the end-to-end setup, troubleshooting, and verification of an enterprise-grade Hybrid Identity Architecture. Over four weeks of implementation, a complete local Active Directory Domain Services (AD DS) environment was designed, bridged to Microsoft Entra ID via Entra Connect Sync, and expanded into cloud device management using Microsoft Intune. 
Resource Name	Role / Function	Operating System	Network Configuration
DC01	Domain Controller, DNS, Entra Connect Sync Host	Windows Server 2022	Dual-NIC: 192.168.1.10 (Internal) + NAT (Internet)
CLIENT11	Workstation Endpoint	Windows 11 Pro	Single NIC: 192.168.1.20 (DNS: 192.168.1.10)
Entra Tenant	Cloud Identity & MDM Service	Microsoft Entra ID / Intune	Primary Domain: labopssyd.onmicrosoft.com
Week 1: Foundation & Cloud Identity
Summary of Activities
•	Virtualization Environment: Configured Oracle VM VirtualBox hypervisor settings and created isolated virtual networks (LabNetwork) to house DC01 and CLIENT11.
•	Cloud Identity Tenant Provisioning: Established Microsoft Entra ID tenant labopssyd.onmicrosoft.com and created cloud administrative users (jsmith@labopssyd.onmicrosoft.com).
•	On-Prem Server Build (DC01): Installed Windows Server 2022 Standard, promoted the server to a Domain Controller for labops.local, and configured static IP (192.168.1.10) and Active Directory DNS.
•	Client Endpoint Deployment (CLIENT11): Installed Windows 11 Pro, assigned host name CLIENT11, and verified cloud connectivity via Entra ID Join.
•	Identity Governance Base: Established custom Organizational Units (LabOps-Objects > Users / Workstations) in AD DS for structured object lifecycle management.
Week 2: Admin Roles, Sync Bridge & Hybrid Join
Days 1 & 2: Admin Roles & Endpoint Reset
•	Dedicated Sync Administrative Identity: Created sync-admin@labopssyd.onmicrosoft.com in Entra ID and assigned the Hybrid Identity Administrator role to isolate synchronization permissions.
•	Local Admin Account Logging: Documented local administrator credentials (labadmin) for workstation and server break-glass access.
•	CLIENT11 Endpoint Re-Provisioning: Reset Windows 11 workstation, renamed host to CLIENT11 via PowerShell (Rename-Computer -NewName 'CLIENT11'), and aligned network profiles.
Day 3: Microsoft Entra Connect Deployment
•	Active Directory Identities: Provisioned user account for Jane Doe (jdoe) in LabOps-Objects > Users with full attributes on DC01.
•	Entra Connect Engine Setup: Executed AzureADConnect.msi on DC01, connecting labops.local to labopssyd.onmicrosoft.com.
Troubleshooting Scenarios
Scenario 1: Setup Wizard 'JavaScript is required' Error
•	Root Cause: Windows Server 2022 IE ESC blocked embedded Trident script execution inside the Entra Connect installer.
•	Resolution: Disabled IE ESC in Server Manager and enabled Active Scripting under inetcpl.cpl (Internet Options > Security).
Scenario 2: Non-Routable .local UPN Suffix Warning
•	Root Cause: labops.local is a non-routable internal domain suffix that cannot be verified in Entra ID.
•	Resolution: Selected "Continue without matching all UPN suffixes to verified domains" in the installer wizard to allow clean mapping to the tenant default UPN.
Day 4: Hybrid Join & Dual-NIC Routing
•	Password Hash Synchronization (PHS) Verification: Validated authentication to myaccount.microsoft.com using Jane Doe's local AD password.
•	Live Attribute Synchronization: Updated Job Title to Security Analyst and Department to Cybersecurity in dsa.msc, triggered Start-ADSyncSyncCycle -PolicyType Delta, and verified live updates in Entra ID.
•	On-Prem Domain Join: Configured CLIENT11 DNS to 192.168.1.10, disconnected pure cloud join, and joined CLIENT11 to the labops.local AD domain.
•	Hybrid Entra Joined Verification: Confirmed CLIENT11 registered as a Hybrid Entra Joined device in the Entra ID portal after sync execution.
Troubleshooting Scenario: Server Dual-NIC Configuration
•	Root Cause: DC01 on an isolated Internal Network lacked internet connectivity to push delta syncs to Entra ID.
•	Resolution: Configured dual-adapter topology on DC01:
o	Adapter 1: Internal Network (192.168.1.10) for local AD/DNS servicing.
o	Adapter 2: NAT for outward Microsoft cloud sync endpoints.
Technical Interview Readiness Highlight
Q: Walk me through building a hybrid identity environment from scratch and handling common roadblocks.
"Starting from a fresh hypervisor, I provisioned an AD DS Domain Controller (DC01) on labops.local and established a cloud tenant on Microsoft Entra ID. I deployed Entra Connect Sync using a dedicated admin identity. During installation, I resolved IE ESC script blocks on Server 2022 and configured UPN matching for non-routable .local domains. To ensure isolated client VMs could authenticate locally while DC01 maintained cloud sync, I implemented a dual-NIC architecture (Internal + NAT). Finally, joining workstations to AD DS automatically registered them as Microsoft Entra Hybrid Joined devices."
Day 5: Group Policy Objects (GPOs) & Security Hardening
•	GPO Creation & Scope Linking: Configured GPO_Workstation_Security_Baseline on DC01 via gpmc.msc and linked it directly to the LabOps-Objects OU.
•	Security Policy Baseline: Defined account lockout settings (5 invalid attempts threshold, 15-minute lockout duration) and established an interactive legal logon notification banner.
•	Client Enforcement & Elevation Fix: Triggered gpupdate /force on CLIENT11. Resolved an initial Access Denied error when querying computer-level policies by executing PowerShell with elevated administrator privileges.
Troubleshooting Scenario: Account Lockout Policy & Scoping Realignment
•	Issue Identified: Entering 5 incorrect password attempts for domain account labops\jdoe on CLIENT11 failed to trigger an account lockout.
•	Root Cause Analysis: Account Lockout Policies and Password Policies for Active Directory domain accounts are evaluated globally and must be linked at the Domain Root (or enforced via Fine-Grained Password Policies / FGPP). The initial lockout configuration in GPO_Workstation_Security_Baseline was linked to the LabOps-Objects sub-OU, which only applies lockout rules to local machine accounts, not domain accounts.
•	Resolution & Verification:
1.	Configured the Account Lockout Policy (5 attempt threshold, 15-minute duration) inside the Default Domain Policy at the root of labops.local.
2.	Executed gpupdate /force on CLIENT11.
3.	Repeated 5 invalid logon attempts for labops\jdoe. Windows enforced the lockout with the error: "The referenced account is currently locked out and may not be logged on to."
4.	Verified on DC01 via dsa.msc that jdoe was flagged as locked out.
Interview Pro-Tip: Domain-wide password and lockout policies must be set at the domain root in the Default Domain Policy or via Fine-Grained Password Policies. If you link lockout settings to a sub-OU GPO, Windows will only enforce those rules against local SAM accounts on those endpoints, leaving domain accounts unaffected.
Week 3: Cloud Tenant Setup & Intune MDM Management
Day 1: Cloud Licensing & MDM Authority Setup
•	Tenant Governance Setup: Created native cloud user globaladmin@labopssyd.onmicrosoft.com with the Global Administrator role. Updated user profile properties to set Usage Location = Australia across accounts.
•	Licensing Activation: Onboarded Entra ID P2 trial for Identity Protection/PIM and activated Microsoft Intune Plan 1 trial via M365 Admin Center to provision the Intune Service Principal (0000000a-0000-0000-c000-000000000000).
•	MDM Authority Configuration: Set MDM user scope to All and MAM user scope to None under Intune Admin Center > Devices > Windows Enrollment to enable automatic background Intune registration during joins.
Troubleshooting Highlights
1.	Tenant Context & Guest SSO Mapping: B2B External Guests cannot access commercial administrative portals. Resolved by provisioning native cloud admin accounts (globaladmin@labopssyd.onmicrosoft.com) in dedicated browser profiles.
2.	Missing Usage Location on License Assignment: License assignment failed due to missing regional attributes. Configured Usage Location = Australia across target user accounts prior to SKU assignment.
3.	Missing Intune Service Principal: Entra ID P2 licenses provide identity features but do not automatically provision the Intune MDM Service Principal until an Intune-capable SKU is added to the directory.
Day 2: Device Onboarding & MDM Auto-Enrollment
•	Target Device: CLIENT11 (Windows 11 Pro) | User Context: jane.doe@labopssyd.onmicrosoft.com
•	Execution: Executed Out-Of-Box Experience (OOBE) cloud onboarding for Windows 11, joined device directly to Microsoft Entra ID (Cloud-only join), and triggered background Intune Automatic MDM Enrollment.
•	Verification Artifacts:
o	AzureAdJoined : YES
o	AzureAdPrt : YES
o	Managed by MDM : YES
Troubleshooting Highlights
1.	Unactivated Windows UI Lockout: Legacy sysdm.cpl looks for local AD DCs, and unactivated Windows 11 builds hide modern Entra ID Join links. Executed sysprep /oobe /reboot to force the native Out-Of-Box Experience.
2.	MDM Terms of Use (invalid_client) Error: Enrollment failed because the user had an Entra ID P2 license but lacked an Intune SKU. Assigned an Intune Plan 1 license to resolve token exchange.
Day 3: Device Configuration Profiles & Compliance Policy Enforcement
•	Target Device: CLIENT11 | Assigned Policies: WIN10-11-Baseline-Compliance, WIN11-Security-Customizations
Completed Actions
1.	Configured an Intune Device Compliance Policy evaluating System Security (Firewall, Antivirus) and Encryption (BitLocker).
2.	Built a custom Settings Catalog Configuration Profile (WIN11-Security-Customizations) enforcing Removable Storage Access Restrictions.
3.	Initiated manual client MDM synchronization via Windows Settings and validated policy delivery.
Verification Artifacts & Results
•	USB Access Control: Successfully blocked read/write access to external drives (E:\ is not accessible. Access is denied).
•	System Security Compliance: Firewall, Defender Antivirus, and Password Policy evaluated as Compliant.
•	Disk Encryption Audit: BitLocker correctly flagged as Not Compliant on unencrypted virtual storage.
Interview Talking Point: Configuration Profiles make direct changes to the endpoint (e.g., locking down USB access), whereas Compliance Policies audit the endpoint state against corporate standards (e.g., checking BitLocker status).
Day 4: Intune Application Packaging & Conditional Access Verification
•	Target Device: CLIENT11 | Apps Deployed: Microsoft 365 Apps Suite (Word, Excel, PowerPoint, Teams), Company Portal (Microsoft Store)
Completed Actions
1.	Authored and targeted an M365 Apps Suite deployment profile via Intune using the Click-to-Run deployment engine.
2.	Configured a required Microsoft Store app integration to deploy the enterprise Company Portal app.
3.	Validated background installation processes (OfficeClickToRun.exe) on CLIENT11.
4.	Observed Conditional Access enforcement triggered by a non-compliant device state (BitLocker check failure).
5.	Adjusted baseline compliance settings to align with VM hardware profiles, synced via Company Portal, and restored compliant access status.
Interview Talking Point: Microsoft 365 Apps use Intune's built-in Office Customization Tool integration to deploy standard Office Click-to-Run XML configurations. Win32 apps and Microsoft Store apps use the Intune Management Extension (IME) agent leveraging winget or .intunewin wrapped installers.
Day 5: Remote Operations & Endpoint Lifecycle Management
•	Target Device: CLIENT11 | Assigned User: jane.doe@labopssyd.onmicrosoft.com
Completed Actions
1.	Triggered and validated remote management actions (Quick Scan, Sync, Restart) via the Intune Admin Center.
2.	Diagnosed client-side push notification latency (Windows Push Notification Services / WNS) and background OMA-DM polling schedules.
3.	Verified local Defender execution status and security telemetry using PowerShell endpoint queries (Get-MpComputerStatus).
4.	Collected remote diagnostic log bundles directly from the Intune console.
Verification Artifacts
•	Remote Defender Quick Scan: Confirmed execution via PowerShell (AntivirusEnabled: True, QuickScanAge: 0).
•	Remote Restart Command: Delivered and validated via native OS desktop sign-out notification ("You are about to be signed out").
Week 4: Automation & Proactive Remediations
Day 1: Intune Management Extension & PowerShell Script Automation
•	Target Device: CLIENT11 | Script Deployed: Win11 - Create LabOps Directory & Log
Completed Actions
1.	Authored a custom PowerShell automation script to enforce local file-system structures and log execution metadata.
2.	Configured and deployed a Platform Script policy in the Intune Admin Center via the Intune Management Extension (IME) engine.
3.	Targeted script deployment to CLIENT11 and forced policy evaluation.
4.	Verified local script execution by confirming folder creation (C:\LabOps_Automation) and inspecting runtime logs (IntuneScript_Log.txt).
Log Verification Output (C:\LabOps_Automation\IntuneScript_Log.txt)
Plaintext
===========================================
LabOps Intune Script Execution Log
Executed On : 08/10/2026 10:42:22
Ran As User : jdoe
Computer    : CLIENT11
===========================================
Status: Verified & Active
Interview Talking Point: Settings Catalog and OMA-URI profiles are best for native MDM policies and registry-backed settings. For custom workflows—such as creating specific directory structures or multi-step environment checks—we deploy PowerShell scripts via the Intune Management Extension (IME) agent in either System or User context.
Day 2: Proactive Remediations & Automated Endpoint Drift Management
•	Target Device: CLIENT11 | Script Package: Win11 - Enforce LabOps Registry Compliance
Completed Actions
1.	Authored paired detection (exit 0 / exit 1) and remediation PowerShell scripts for automated configuration drift control.
2.	Enabled Windows Licensing Verification for Endpoint Analytics and Proactive Remediations in Tenant Administration.
3.	Deployed a Remediation Script Package via Intune running in the SYSTEM context.
4.	Diagnosed client-side SideCar execution intervals, 64-bit/32-bit execution context handling, and verified local registry compliance (HKLM:\SOFTWARE\LabOps).
Telemetry & Verification Artifacts
•	Local Registry Path: HKLM\SOFTWARE\LabOps
•	DWORD Value: ComplianceCheck = 1
•	Log Verification Path: C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\HealthScripts.log
•	Remediation State: Fully Verified & Compliant
Interview Pro-Tip: The Intune Management Extension defaults to a 32-bit PowerShell process unless "Run script in 64-bit PowerShell Host" is set to Yes in the script package settings. Running in 32-bit context causes Windows Registry Redirection to write keys into HKLM\SOFTWARE\WOW6432Node instead of native HKLM\SOFTWARE. Additionally, Proactive Remediations run on an 8-hour SideCar schedule rather than executing immediately upon policy sync.
