#Requires -version 2.0
##
##  Author Richard Siddaway
##    Version 0.1 - Inital Release  November 2010
###############################################
##
#########################################################################
#########################################################################
####  Functions:
####    get-environment 
####    new-environment 
####    set-environment 
####    remove-environment 
####
#########################################################################
#########################################################################
function get-environment {
param ([string]$name = "")
 
 if (!$name){Get-ChildItem -Path env:}
 else{Get-ChildItem -Path env:\$name}  

}
#########################################################################
function new-environment {
param (
 [string][ValidateNotNullOrEmpty()]$name,
 [string][ValidateNotNullOrEmpty()]$value,
 [switch]$perm,
 [switch]$machine

)

 if (-not $perm) {New-Item -Path env:\ -Name $($name) -Value $($value)}
 else {
  if ($machine){$type = "Machine"}
  else {$type = "User"}
  [System.Environment]::SetEnvironmentVariable($name, $value, $type)
 }
}
#########################################################################
function set-environment {
param (
 [string][ValidateNotNullOrEmpty()]$name,
 [string][ValidateNotNullOrEmpty()]$value,
 [switch]$perm,
 [switch]$machine

)

 if (-not $perm) {Set-Item -Path env:\$($name) -Value $($value)}
 else {
  if ($machine){$type = "Machine"}
  else {$type = "User"}
  [System.Environment]::SetEnvironmentVariable($name, $value, $type)
 }
 
 Get-Item -Path env:\$($name)
}
#########################################################################
function remove-environment {
param (
 [string][ValidateNotNullOrEmpty()]$name,
 [switch]$perm,
 [switch]$machine
)
$value = ""
if (-not $perm) {Remove-Item -Path env:\$($name) -Force}
else {
 if ($machine){$type = "Machine"}
 else {$type = "User"}
 [System.Environment]::SetEnvironmentVariable($name, $value, $type)
}
}