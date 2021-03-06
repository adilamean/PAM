function dismount-adsnapshot{
[CmdletBinding()]
param(
 [Parameter(ParameterSetName="Index")]
 [string]$index,
 
 [Parameter(ParameterSetName="GUID")]
 [string]$guid,
 
 [Parameter(ParameterSetName="All")]
 [switch]$all
 
 )
PROCESS{
 if ( -not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") ){
   Throw "Must run PowerShell as ADMINISTRATOR to perform these actions"
 }
 
 switch ($psCmdlet.ParameterSetName) {
   Index {ntdsutil snapshot "list all" "unmount $index" quit quit}
   GUID  {ntdsutil snapshot "unmount $guid" quit quit}
   All   {ntdsutil snapshot "unmount *" quit quit}
 }
  
}#process

<#
.SYNOPSIS
 Dismounts AD snapshots
.PARAMETER  <Parameter-Name>
index

.PARAMETER  <Parameter-Name>
guid

.PARAMETER  <Parameter-Name>
all

Dismounts all snapshots

.EXAMPLE
 dismount-adsnapshot -index 8                                                                                                                                                  
index of snapshot retrieved by get-adsnapshot
 
 dismount-adsnapshot -guid 1bd79744-df2b-46f1-99e2-cd61adf072f8                                                                                                                
 guid of snapshot retrieved by get-adsnapshot
 
 dismount-adsnapshot -all  

#>


}