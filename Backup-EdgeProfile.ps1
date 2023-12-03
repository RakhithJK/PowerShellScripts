<#
    .SYNOPSIS
    Backs up Microsoft Edge profiles into a zip file
	
    THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE 
    RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
	
    .DESCRIPTION
    Script Features
    * Backs up the Microsoft Edge profile to a zip archive
	
    .NOTES
    Author: /RakhithJK
	
    Version: 0.01
    Initial draft
	
    .INPUTS
    Microsoft Edge channel type
	
    .EXAMPLE
    .\Backup-EdgeProfile.ps1 -Channel 'Stable' -ExportPath 'C:\myexportfilepath\'
	
#>

#====================================================================================================
#                                             Requires
#====================================================================================================
#region Requires

#Requires -Version 5.0
#-- Requires -ShellId <ShellId>
#-- Requires -RunAsAdministrator
#-- Requires -PSSnapin <PSSnapin-Name> [-Version <N>[.<n>]]

#endregion Requires

#====================================================================================================
#                                             Parameters
#====================================================================================================
#region Parameters

[cmdletbinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Stable', 'Beta', 'Dev', 'Canary')]
    [string]$Channel,

    [Parameter(Mandatory = $true)]
    [string]$ExportPath
)


#endregion Parameters

#====================================================================================================
#                                             Initialize
#====================================================================================================
#region Initialize


# Set ErrorActionPreference
$ErrorActionPreference = 'Stop'

# Is Edge running?
$isMSEdgeRunning = Get-Process -Name 'msedge' -ErrorAction Continue 2>$null

# Temp path
$tempPath = "$env:TEMP\edgebackup"

#endregion Initialize

#====================================================================================================
#                                             Main
#====================================================================================================
#region Main


if ($null -ne $isMSEdgeRunning) {
    Write-Host 'Microsoft Edge is running. Please exit and run again.' -ForegroundColor 'Red'
    exit
} else {
    Write-Verbose 'Checking temp directory.'
    if (!(Test-Path -Path $tempPath)) {
        Write-Verbose 'No temp directory found, creating directory.'
        New-Item -Path $tempPath -ItemType 'Directory' 2>$null
    } else {
        Write-Verbose 'Temp directory found, removing any files from previous runs.'
        Remove-Item -Path "$tempPath\*" -Recurse -Force
    }
}

Write-Verbose 'Copying edge profile to temp directory.'
switch ($channel) {
    Stable { Copy-Item -Path "$($env:LOCALAPPDATA)\Microsoft\Edge\*" -Recurse -Destination "$tempPath" }
    Beta { Copy-Item -Path "$($env:LOCALAPPDATA)\Microsoft\Edge Beta\*" -Recurse -Destination "$tempPath" }
    Dev { Copy-Item -Path "$($env:LOCALAPPDATA)\Microsoft\Edge Dev\*" -Recurse -Destination "$tempPath" }
    Canary { Copy-Item -Path "$($env:LOCALAPPDATA)\Microsoft\Edge SxS\*" -Recurse -Destination "$tempPath" }
}

Write-Verbose 'Export edge windows registry keys.'
switch ($channel) {
    Stable { Invoke-Command { reg export 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Edge\PreferenceMACs' "$tempPath\edge.reg" } }
    Beta { Invoke-Command { reg export 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Edge Beta\PreferenceMACs' "$tempPath\edgebeta.reg" } }
    Dev { Invoke-Command { reg export 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Edge Dev\PreferenceMACs' "$tempPath\edgedev.reg" } }
    Canary { Invoke-Command { reg export 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Edge SxS\PreferenceMACs' "$tempPath\edgecanary.reg" } }
}


Write-Verbose 'Compressing export files and reg key to zip file.'
Compress-Archive -Path "$tempPath\*" -DestinationPath "$exportPath\edge_backup.zip" -CompressionLevel 'Optimal' -Force

Write-Verbose 'Cleaning up exported files.'
Remove-Item -Path $tempPath -Recurse -Force

#endregion Main
