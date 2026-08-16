# Create a dedicated tracking folder
$FolderPath = "C:\LabOps_Automation"
if (-not (Test-Path -Path $FolderPath)) {
    New-Item -Path $FolderPath -ItemType Directory
}

# Output environment and execution details to a log file
$LogPath = "$FolderPath\IntuneScript_Log.txt"
$LogContent = @"
===========================================
LabOps Intune Script Execution Log
Executed On : $(Get-Date)
Ran As User : $env:USERNAME
Computer    : $env:COMPUTERNAME
===========================================
"@

Set-Content -Path $LogPath -Value $LogContent
