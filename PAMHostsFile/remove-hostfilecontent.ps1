function remove-hostfilecontent {
 [CmdletBinding()]
 param (
  [parameter(Mandatory=$true)]
  [string]$IPAddress,
  
  [parameter(Mandatory=$true)]
  [string]$computer
 )
 $file = Join-Path -Path $($env:windir) -ChildPath "system32\drivers\etc\hosts"
 if (-not (Test-Path -Path $file)){
   Throw "Hosts file not found"
 }
 Write-Verbose "Remove IP Address"
 $data = ((Get-Content -Path $file) -notmatch "$ip\s+$computer")
  
 $data 
  
 Set-Content -Value $data -Path $file -Force -Encoding ASCII 
 
 <# 
.SYNOPSIS
Removes an entry from the hosts file

.DESCRIPTION
Removes an entry from the hosts file using a computer name and 
IPv4 or IPv6 address as parameters. No checking is performed to 
test if other entries for that machine already exists.

.PARAMETER  Computer
A string representing a computer name

.PARAMETER  IPAddress
A string storing an IPv4 or IPv6 Address

.EXAMPLE
remove-hostfilecontent -IPAddress 10.10.54.115 -computer W08R2SQL12

Removes a IPv4 record for system W08R2SQL12

.EXAMPLE
remove-hostfilecontent -IPAddress fe80:0000:0000:0000:4547:ee51:7aac:521e -computer W08R2SQL12

Removes a IPv6 record for system W08R2SQL12

.INPUTS
Parameters 

.OUTPUTS
None

.NOTES
Removes IPv4 or IPv6 entries
#>
 
 
}