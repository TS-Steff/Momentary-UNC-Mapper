<#
    .SYNOPSIS
        Maps network drives as long as the script runs and unmaps them on abort
        Used for example after connecting to a VPN

        Author: TS-Management GmbH, Stefan Müller, kontakt@ts-management.ch
        Date: 2024-10-03
        Version: 1.0

    .DESCRIPTION
        1. Modify $driveMappings to your requirements
        2. Change user domain and username
        3. run skript

    .HISTORY
        - 1.0 (2024-10-03): Initial release.

    .NOTES
        Date created: 2024-10-03
#>

# Define an array of objects, each containing a drive letter and network path
$driveMappings = @(
    @{ DriveLetter = "E"; NetworkPath = "\\<server>\<folder>" },
    @{ DriveLetter = "F"; NetworkPath = "\\<server>\<folder>" }
)

$user = "<domain>\<user>"
$credentials = Get-Credential -Credential $user

# Function to map a drive
function Map-NetworkDrive {
    param($driveLetter, $networkPath)
    Write-Host "Mapping drive $driveLetter to $networkPath"
    New-PSDrive -Name $driveLetter -PSProvider FileSystem -Root $networkPath -Credential $credentials -Persist -Scope Global
}

# Function to unmap a drive
function Unmap-NetworkDrive {
    param($driveLetter)
    Write-Host "Unmapping drive $driveLetter..."
    Remove-PSDrive -Name $driveLetter
}

# Map all drives
foreach ($mapping in $driveMappings) {
    Map-NetworkDrive -driveLetter $mapping.DriveLetter -networkPath $mapping.NetworkPath
}

# Try to keep the script running and catch termination
try {
    Write-Host "Drives mapped. The script will now run indefinitely. Close this window to unmap the drives."
    # Keep the script running
    while ($true) {
        Start-Sleep -Seconds 10
    }
} finally {
    # This block runs when the script is stopped
    foreach ($mapping in $driveMappings) {
        Unmap-NetworkDrive -driveLetter $mapping.DriveLetter
    }
    Write-Host "All drives unmapped. Exiting script."
}