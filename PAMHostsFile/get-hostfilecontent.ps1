function get-hostfilecontent {
 param ([switch]$all)
 $file = Join-Path -Path $($env:windir) -ChildPath "system32\drivers\etc\hosts"
 if (-not (Test-Path -Path $file)){
   Throw "Hosts file not found"
 }
 $cont = Get-Content -Path $file 
 if ($all) {
   $cont
 }
 else {
   $cont | 
   where {!$_.StartsWith("#")} |
   foreach {
     if ($_ -ne ""){
       $data = $_ -split " ",2
       New-Object -TypeName PSObject -Property @{
         Server = $data[1].Trim()
         IPAddress = $data[0].Trim()
       }
     }
   }
 }
 
 <# 
.SYNOPSIS
Reads all entries from the hosts file

.DESCRIPTION
Reads all entries from the hosts file 

.EXAMPLE
get-hostfilecontent

.INPUTS
None 

.OUTPUTS
None

.NOTES

#>

}