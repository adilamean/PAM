function get-reliabilityrecords{
[CmdletBinding()]
param (
 [parameter(ValueFromPipeline=$true,
   ValueFromPipelineByPropertyName=$true)]
  [string]$computer=".",
  
  [string]
  [ValidateSet("System", "Application")]
  $logfile,
  
  [string]
  [ValidateSet(
    "Microsoft-Windows-WindowsUpdateClient ",
     "Application Error", 
     "MsiInstaller", 
     "Microsoft-Windows-UserPnp",
     "Application Hang", 
     "Application-Addon-Event-Provider",
     "EventLog")]
     $source
  
)
BEGIN{
 $filt = $null
 if ($logfile) {$filt += "LogFile = '$logfile'"}
 if ($source) {$filt += "AND SourceName ='$source'"}
 if ($filt){ 
   if ($filt.StartsWith("AND ")){$filt = $filt.Remove(0, 4)}
   Write-Debug $filt   
 }
 
}#begin

PROCESS{
 if ($filt){
   Get-WmiObject -Class Win32_ReliabilityRecords -Filter "$filt" -ComputerName $computer |
   select ComputerName, EventIdentifier, InsertionStrings, Logfile, Message,
   ProductName, RecordNumber, SourceName, 
   @{N="TimeGenerated"; E={$_.ConvertToDatetime($_.TimeGenerated)}}, 
   User
 }
 else{
   Get-WmiObject -Class Win32_ReliabilityRecords -ComputerName $computer |
   select ComputerName, EventIdentifier, InsertionStrings, Logfile, Message,
   ProductName, RecordNumber, SourceName, 
   @{N="TimeGenerated"; E={$_.ConvertToDatetime($_.TimeGenerated)}}, 
   User
 }  

}#process
END{}#end

<#
.SYNOPSIS
 Gets the Reliability Records of the System. This is only valid for Windows 7 
 and Windows Server 2008 R2

.DESCRIPTION
Uses the Win32_ReliabilityRecords class. Records can be filtered by log file and 
source name

.PARAMETER  <Parameter-Name>
Computer

A string containing the computer name to access.


.PARAMETER  <Parameter-Name>
source

A string containing the source name used to write to the event logs.

.PARAMETER  <Parameter-Name>
logfile

A string containing the event log file  name. 
Accepted values are "System" and "Application"

.EXAMPLE
get-reliabilityrecords -source "Application Hang" -debug | 
Format-Table TimeGenerated, ProductName, Message –wrap –AutoSize   

Returns the records from the Application Hang source

.EXAMPLE
get-reliabilityrecords  -logfile application  | 
Format-Table TimeGenerated, ProductName, Message –wrap –AutoSize    

Returns the records from the Application event log
#>

}