function clear-hostfilecontent {
 [CmdletBinding()]
 param ()
 $file = Join-Path -Path $($env:windir) -ChildPath "system32\drivers\etc\hosts"
 if (-not (Test-Path -Path $file)){
   Throw "Hosts file not found"
 }
 Write-Verbose "Remove IP Addresses"
 $data = ((Get-Content -Path $file) -notmatch "^\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b") 
 
 $data 
  
 Set-Content -Value $data -Path $file -Force -Encoding ASCII 
 
<# 
.SYNOPSIS
Removes all entries from the hosts file

.DESCRIPTION
Removes all entries from the hosts file leaving the
default content from Windows install

.EXAMPLE
clear-hostfilecontent

Removes all entries from local hosts file

.INPUTS
None 

.OUTPUTS
None

.NOTES
No backup is taken prior to removing entries

#>
  
}