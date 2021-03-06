function get-systemrestorepoint {
[CmdletBinding()]
param ( 
[string]$computername="."
) 

$test = Test-Connection -ComputerName $computername -Count 1
if (-not ($test)){Throw "Computer $computername not reachable"}

 Get-WmiObject -Namespace 'root\default' -Class SystemRestore `
  -ComputerName $computername | 
 sort SequenceNumber -Descending |
 Format-Table SequenceNumber, 
 @{Name="Date"; Expression={$($_.ConvertToDateTime($_.CreationTime))}},
 Description -AutoSize
}

function new-systemrestorepoint {
[CmdletBinding()]
param ( 
[string]$computername=".",
[string]$description="Testing123"
) 

$test = Test-Connection -ComputerName $computername -Count 1
if (-not ($test)){Throw "Computer $computername not reachable"}

 $sr = [wmiclass]"\\$computername\root\default:SystemRestore"
 $sr.CreateRestorePoint($description, 0, 100)
}