# Detection Script: Checks if the registry value exists and equals 1
$Path  = "HKLM:\SOFTWARE\LabOps"
$Name  = "ComplianceCheck"

if (Test-Path $Path) {
    $Value = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name
    if ($Value -eq 1) {
        Write-Output "Compliant: Registry key exists and is set to 1."
        exit 0 # Exit 0 means compliant (no remediation needed)
    }
}

Write-Output "Non-Compliant: Registry key missing or incorrect."
exit 1 # Exit 1 triggers the Remediation script!
