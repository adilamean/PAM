function mount-addatabase{
[CmdletBinding()]
param()

## assumes only one snapshot mounted
PROCESS{
 if ( -not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") ){
   Throw "Must run PowerShell as ADMINISTRATOR to perform these actions"
 }
 
 if (ntdsutil snapshot "list mounted" quit quit | Select-String -Pattern "No snapshots found" -SimpleMatch) {
   Throw "No snapshots mounted"
 }
 
 $path = (ntdsutil snapshot "list mounted" quit quit | Select-String -Pattern "SNAP_" -SimpleMatch ) -split "}"
 
 $dbpath = "$($path[1].Trim())Windows\NTDS\ntds.dit"
 $dbpath
 
dsamain -dbpath: $dbpath -ldapPort: 60000 -sslPort: 60001 -gcPort: 60002 -gcSslPort: 60003
} #process

<#
.SYNOPSIS
 Mounts AD database using dsamain. Assumes only one snapshot mounted

.EXAMPLE
 mount-addatabase
   
#>

}