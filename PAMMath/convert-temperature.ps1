function convert-temperature{
param(
 [double]$temperature,
 
 [parameter(Mandatory=$true)]
 [string]
 [ValidateSet("C", "F", "K")]
 $inputTemp,
 
 [parameter(Mandatory=$true)]
 [string]
 [ValidateSet("C", "F", "K")]
 $outputTemp
)

Write-Verbose "Convert to Centigrade"
switch($inputTemp){
 "C" {$data = $temperature}
 "F" {$data = ($temperature -32) * (5/9 )}
 "K" {$data = $temperature - 273.15}
}

switch($outputTemp){
 "C" {$output = $data}
 "F" {$output = ($data * (9/5)) + 32 }
 "K" {$output = $data + 273.15}
}
[math]::round($output,2)
}