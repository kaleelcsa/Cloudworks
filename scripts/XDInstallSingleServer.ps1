<#
    
    Copyright © 2013-2014 Citrix Systems, Inc. All rights reserved.
	
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
This script will install a simple "one server" XenDesktop on the local machine

.DESCRIPTION
Installs the XenDesktop Controller, Citrix Studio and Storefront on the local server. Will also install a 
local SQL Server if not already present. Requires access to the XenDeskop DVD image.

.NOTES
    KEYWORDS: PowerShell, Citrix
    REQUIRES: PowerShell Version 2.0 

.LINK
     http://community.citrix.com/
#>

Param (
    [string]$InstallerPath = "D:\x64\XenDesktop Setup",
      [switch]$Reboot 
)
"AS-NET-Framework"
function Install-Storefront ($InstallerPath) {
    try {
		$parent = Split-Path -parent $InstallerPath
        $logdir = "C:\Windows\Temp\Citrix"
        if (-not (Test-Path $logdir)) {
            New-Item -Path $logdir -ItemType Directory
        }
				
		$privSvc =  Join-Path -Path $parent -ChildPath "Citrix Desktop Delivery Controller\CitrixPrivilegedService_x64.msi"
		$msiargs = "/i ""$privSvc"" /quiet"
		$msiexec = "${env:windir}\system32\msiexec.exe"
		Start-ProcessAndWait $msiexec $msiargs

        $installargs = "-noconsole -silent -logfile ${logdir}\StoreFrontLog.txt"     
        $installer = Join-Path -Path $parent -ChildPath "StoreFront\CitrixStoreFront-x64.exe"
        Start-ProcessAndWait $installer $installargs
		

    } catch {
      Write-Log "Error attempting to install Storefront"
      Write-Log $error[0]      
    }
}

#
# Main
#
$ErrorActionPreference = "Stop"
Import-Module CloudworksTools
Start-Logging
try { 
     # Seems to be a problem with the installation of pre-requisites if .NET 3.5.1 not installed.
    Install-Feature "AS-NET-Framework"

    # Problem with storefront installation used from the XD installer.
    $installargs = "/components controller,desktopstudio /quiet /configure_firewall /noreboot"
    $installer = Join-Path -Path $InstallerPath -ChildPath "XenDesktopServerSetup.exe"
    Start-ProcessAndWait $installer $installargs
    
    Install-StoreFront $InstallerPath
    if ($Reboot) {
        Restart-Computer -Force
    }
} 
finally {
    Stop-Logging
}