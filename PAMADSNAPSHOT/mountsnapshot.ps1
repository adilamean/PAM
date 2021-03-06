function mount-adsnapshot{
[CmdletBinding()]
param(
 [Parameter(ParameterSetName="Index")]
 [string]$index,
 
 [Parameter(ParameterSetName="GUID")]
 [string]$guid
 )
PROCESS{
 if ( -not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") ){
   Throw "Must run PowerShell as ADMINISTRATOR to perform these actions"
 }
 
 switch ($psCmdlet.ParameterSetName) {
   Index {ntdsutil snapshot "list all" "mount $index" quit quit}
   GUID {ntdsutil snapshot "mount $guid" quit quit}
 }
  
}#process

<#
.SYNOPSIS
 Mounts AD snapshots
.PARAMETER  <Parameter-Name>
index

.PARAMETER  <Parameter-Name>
guid

.EXAMPLE
 mount-adsnapshot -index 1
 index of snapshot retrieved by get-adsnapshot      

 mount-adsnapshot -guid 0c7cb1d2-7f0a-43fe-baac-b6bad2fb5ad7
 guid of snapshot retrieved by get-adsnapshot
#>

}