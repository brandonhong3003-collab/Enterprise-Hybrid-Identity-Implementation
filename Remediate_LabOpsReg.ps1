# Remediation Script: Creates the registry key if missing
$Path  = "HKLM:\SOFTWARE\LabOps"
$Name  = "ComplianceCheck"

if (-not (Test-Path $Path)) {
    New-Item -Path $Path -Force | Out-Null
}

Set-ItemProperty -Path $Path -Name $Name -Value 1 -Type DWord -Force
Write-Output "Remediated: Created HKLM:\SOFTWARE\LabOps\ComplianceCheck = 1"