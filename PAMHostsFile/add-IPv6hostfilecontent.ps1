function add-IPv6hostfilecontent {
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
 $data = Get-Content -Path $file 
 $data += "$IPAddress  $computer"
 Set-Content -Value $data -Path $file -Force -Encoding ASCII 
 
<# 
.SYNOPSIS
Adds an IPv6 entry to the hosts file

.DESCRIPTION
Adds an entry to the hosts file using a computer name and 
IPv6 address as parameters. No checking is performed to 
test if an entry for that machine already exists.

.PARAMETER  Computer
A string representing a computer name

.PARAMETER  IPAddress
A string storing an IPv6 Address. No checking of the validity 
of the address is performed.

.EXAMPLE
add-hostfilecontent -IPAddress fe80:0000:0000:0000:4547:ee51:7aac:521e  -computer W08R2SQL12
                                            
Adds a IPv6 record for system W08R2SQL12

.INPUTS
Parameters 

.OUTPUTS
None

.NOTES
Use add-hostfilecontent for IPV4 addresses

#>
 
}