function new-temperaturechart {
param (
 [int]$start = -10,
 [int]$end = 30,
 
 [parameter(Mandatory=$true)]
 [string]
 [ValidateSet("C", "F", "K")]
 $inputTemp

)

if ($start -ge $end){Throw "End temperature must be greater than starting temperature"}

$start..$end | 
foreach {
 $point = New-Object -TypeName PSObject -Property @{
  F = convert-temperature -temperature $_ -inputTemp $inputTemp -outputTemp F
  C = convert-temperature -temperature $_ -inputTemp $inputTemp -outputTemp C
  K = convert-temperature -temperature $_ -inputTemp $inputTemp -outputTemp K
 }
 $point
}  

}