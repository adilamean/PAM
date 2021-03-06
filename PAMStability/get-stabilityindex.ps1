function get-stabilityindex {
[CmdletBinding()]
param (
 [parameter(ValueFromPipeline=$true,
   ValueFromPipelineByPropertyName=$true)]
 [string]$computer="."
) 
BEGIN{}
PROCESS{ 
 Get-WmiObject -Class Win32_ReliabilityStabilityMetrics -ComputerName $computer |
 select @{N="TimeGenerated"; E={$_.ConvertToDatetime($_.TimeGenerated)}}, 
 SystemStabilityIndex
}#process
END{} 
<#
.SYNOPSIS
 Gets the Stability Index of the System. This is only valid for Windows 7 
 and Windows Server 2008 R2

.DESCRIPTION
Uses the Win32_ReliabilityStabilityMetrics class to retrieve the stability index. Values are
generated every hour. The period of generation is the hour up to the time generated.

.PARAMETER  <Parameter-Name>
Computer

A string containing the computer name to access.

.EXAMPLE
get-stabilityindex

Returns the stability index data for the local system

.EXAMPLE
get-stabilityindex -computer server02

Returns the stability index data for a remote system
#>
}