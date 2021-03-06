function get-adsnapshot{
[CmdletBinding()]
param(
 [switch]$mounted
)
PROCESS{
 if ( -not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") ){
   Throw "Must run PowerShell as ADMINISTRATOR to perform these actions"
 }
 
 if ($mounted) { ntdsutil snapshot "list mounted" quit quit }
 else { ntdsutil snapshot "list all" quit quit }
}#process

<#
.SYNOPSIS
 Lists available AD snapshots

.PARAMETER  <Parameter-Name>
mounted

.EXAMPLE
 get-adsnapshot
  
 get-adsnapshot -mounted 
#>

}