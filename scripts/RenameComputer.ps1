<#
    
    Copyright © 2013 Citrix Systems, Inc. All rights reserved.
	
	Permission is hereby granted, free of charge, to any person obtaining
	a copy of this software and associated documentation files (the
	'Software'), to deal in the Software without restriction, including
	without limitation the rights to use, copy, modify, merge, publish,
	distribute, sublicense, and/or sell copies of the Software, and to
	permit persons to whom the Software is furnished to do so, subject to
	the following conditions:
  
	The above copyright notice and this permission notice shall be
	included in all copies or substantial portions of the Software.
  
	THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

.SYNOPSIS
This script will rename the computer

.DESCRIPTION

.NOTES
    KEYWORDS: PowerShell, Citrix
    REQUIRES: PowerShell Version 2.0 

.LINK
     http://community.citrix.com/
#>

Param (
    [Parameter(Mandatory=$true)]
    [string]$ComputerName,
    [scriptblock]$OnBoot,
    [switch]$Reboot = $true
)
$ErrorActionPreference = "Stop"
Import-Module CloudworksTools

Start-Logging
try {

    $computer = Get-WmiObject Win32_ComputerSystem
    if ($computer.Name.ToLower() -ne $ComputerName.ToLower()) {
        $computer.rename($ComputerName)
        Write-Output "Renamed computer $ComputerName"
     } else {
        Write-Output "Computer is already named $ComputerName (continuing)"
     }
     if ($OnBoot) {
        New-RunOnceTask $OnBoot
    }
}
finally {
    Stop-Logging
}
if ($Reboot) {
    Restart-Computer -Force
}



