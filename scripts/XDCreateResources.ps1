<#
    Copyright © 2013 Citrix Systems, Inc. All rights reserved.

.SYNOPSIS
    This script will create a XenDesktop hosting unit connected to a cloud.

.DESCRIPTION
    Create a hosting unit connected to a cloud. Requires XenDesktop snapins Citrix.* to be installed
    (so run it on a XenDesktop controller)

.NOTES
    KEYWORDS: PowerShell, Citrix
    REQUIRES: PowerShell Version 2.0 

.LINK
     http://community.citrix.com/
#>
Param (
    [string]$ConnectionName = "CloudConnection",
    [string]$HostingUnitName = "CloudResources",
    [string]$CloudStackUrl =  "http://192.168.2.1:8080/client/api",
    [string]$ApiKey = "NTbOqdGSM2KWzS0GIMO9fBO6TiKb2oEKo59t7hmPWNna4rQtftX3sarCO-sAMXfL8l3zm55mND__53bV-wyZrA",
    [string]$SecretKey = "G379F22wYG_ISyG4Y-0saikSyUQNf9hVozwcep-LqsGNRvSBx81bN-mZ1bDyckMYNItYypIfzjU-MlFrS5IEIw",
    [string]$ZoneId = "2d1fe3c7-33bd-4e02-94a9-55ba34321942",
    [string]$NetworkId = "32765e43-93e2-43fb-9ff7-2b3add82edee",
    [string]$ConnectionType = "CloudPlatform"
)
$ErrorActionPreference = "Stop"
Add-PSSnapin -Name Citrix.*
Import-Module XenDesktopTools

$connection = Get-Item -Path "xdhyp:\Connections\*" | Where-Object {$_.PSChildName -eq $ConnectionName}
if ($connection -eq $null) {
  
   $connection = New-Item -Path "xdhyp:\Connections" -Name $ConnectionName -ConnectionType $ConnectionType -HypervisorAddress $CloudStackUrl -UserName $ApiKey -Password $Secretkey -Persist
    
   New-BrokerHypervisorConnection -HypHypervisorConnectionUid $connection.HypervisorConnectionUid
   
   $zone = Get-AvailabilityZones -ConnectionName $ConnectionName | Where-Object {$_.Id -eq $ZoneId}
   
   $network = Get-Networks -ConnectionName $ConnectionName | Where-Object {$_.Id -eq $NetworkId}
   
   $hupath = "xdhyp:\HostingUnits\$HostingUnitName"
   $rootpath = "xdhyp:\Connections\$ConnectionName"
   
    New-Item -Path $hupath -HypervisorConnectionName $ConnectionName -AvailabilityZonePath $zone.FullPath -NetworkPath $network.FullPath -RootPath $rootpath
   
   
} else {
    "Connection $ConnectionName already exists"
}

