<#
    Copyright © 2014 Citrix Systems, Inc. All rights reserved.

.SYNOPSIS
This script will install the specified Citrix license.

.DESCRIPTION

.NOTES
    KEYWORDS: PowerShell, Citrix
    REQUIRES: PowerShell Version 2.0 

.LINK
     http://community.citrix.com/stackmate
#>
Param ( 
    [Parameter(Mandatory=$true)]
    [string]$Path,
    [switch]$Reboot=$true
)

$ErrorActionPreference = "Stop"
$serviceName = "Citrix Licensing"

Copy-Item -Path $Path -Destination "C:\Program Files (x86)\Citrix\Licensing\MyFiles"

if ($Reboot) {
    Restart-Computer -Force
}
