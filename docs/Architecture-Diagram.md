graph TD
    subgraph Cloud ["☁️ Microsoft Cloud Infrastructure"]
        Entra["Microsoft Entra ID Tenant<br/>(labopssyd.onmicrosoft.com)"]
        Intune["Microsoft Intune MDM<br/>(Policy & Proactive Remediations)"]
        Entra <--> Intune
    end

    subgraph OnPrem ["🏢 On-Premises Network (192.168.1.0/24)"]
        subgraph DC ["DC01 (Windows Server 2022)"]
            AD["Active Directory DS<br/>(labops.local)"]
            DNS["AD DNS Server<br/>(192.168.1.10)"]
            Sync["Entra Connect Sync Engine<br/>(PHS Baseline)"]
            NIC1["NIC 1: Internal Network<br/>(192.168.1.10)"]
            NIC2["NIC 2: NAT<br/>(Internet Access)"]
        end

        subgraph Client ["CLIENT11 (Windows 11 Pro)"]
            Workstation["Endpoint<br/>(192.168.1.20)"]
            IME["Intune Management Extension<br/>(64-bit PowerShell Host)"]
        end
    end

    %% Sync & Authentication Connections
    Sync -->|Password Hash Sync / Delta Sync| Entra
    Workstation -->|1. Domain Join & Auth| AD
    Workstation -->|2. Hybrid Entra Join & MDM| Entra
    Intune -->|3. Compliance & Remediations| IME
