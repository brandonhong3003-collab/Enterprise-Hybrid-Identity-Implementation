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
|  Internal Hypervisor Network (192.168.1.0/24)                                        |
|                                                                                     |
|   +------------------------------------+          +-----------------------------+   |
|   | DC01 (Windows Server 2022)         |          | CLIENT11 (Windows 11 Pro)   |   |
|   | • Domain Controller: labops.local  |          | • Hybrid Entra ID Joined    |   |
|   | • DNS: 192.168.1.10                | <======> | • Intune MDM Enrolled       |   |
|   | • Dual-NIC (Internal + NAT)        |          | • IP: 192.168.1.20          |   |
|   | • Entra Connect Sync Engine        |          |                             |   |
|   +------------------------------------+          +-----------------------------+   |
+-------------------------------------------------------------------------------------+
