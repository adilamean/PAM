#Requires -version 2.0
##
##  Author Richard Siddaway
##    Version 0.1 - Inital Release  June 2010
###############################################
##
#########################################################################
#########################################################################
####
####  Conversion Functions
####
#########################################################################
#########################################################################
function ConvertTo-Hex{
#  .ExternalHelp   Maml-PAMMath.XML
[CmdletBinding()]
param (
    [Parameter(ValueFromPipeline=$true)]
    [int64]$inputvalue =0
)
    [convert]::ToString($inputvalue,16)
}

function ConvertTo-Binary{
#  .ExternalHelp   Maml-PAMMath.XML
[CmdletBinding()]
param (
    [Parameter(ValueFromPipeline=$true)]
    [int64]$inputvalue =0
)
    [convert]::ToString($inputvalue,2)
}

function ConvertTo-Decimal{
#  .ExternalHelp   Maml-PAMMath.XML
[CmdletBinding()]
param (
    [Parameter(ValueFromPipeline=$true)]
    [string]$inputvalue,

    [Parameter(ParameterSetName="Binary")]        
    [switch]$binary,
    
    [Parameter(ParameterSetName="Hex")]      
    [switch]$hex
)
    switch ($psCmdlet.ParameterSetName) {
        Binary { 
                    Test-Binary $inputvalue
                    $ret = [convert]::ToInt64($inputvalue.Trim(),2)
                    break 
               }
        Hex    { 
                    Test-Hex $inputvalue
                    $ret = [convert]::ToInt64($inputvalue.Trim(),16)
                    break
               }
    }
return $ret
}

#########################################################################
#########################################################################
####
####  Test Functions
####
#########################################################################
#########################################################################
function Test-Binary {
#  .ExternalHelp   Maml-PAMMath.XML
param(
    [string]$inputvalue
)
    $chars = $inputvalue.Trim().ToCharArray()
    foreach ($char in $chars){
        if (-not($char -match '0|1')){
            Throw "$inputvalue is not a valid binary number"
        }
    }    
}

function Test-Hex {
#  .ExternalHelp   Maml-PAMMath.XML
param(
    [string]$inputvalue
)
    $chars = $inputvalue.Trim().ToCharArray()
    foreach ($char in $chars){
        if (-not($char -match '[0-9]' -or $char -match '[A-F]')){
            Throw "$inputvalue is not a valid hex number"
        }
    }  
}
#########################################################################
#########################################################################
####
####  Binary Functions
####
#########################################################################
#########################################################################
function Get-BinarySum {
#  .ExternalHelp   Maml-PAMMath.XML
param(
    [string]$inputvalue1,
    [string]$inputvalue2
)
## check valid binary numbers
##  moved this to a validation test
    Test-Binary $inputvalue1
    Test-Binary $inputvalue2

    $sum = (ConvertTo-Decimal -inputvalue $inputvalue1 -binary) + (ConvertTo-Decimal -inputvalue $inputvalue2 -binary)

    ConvertTo-Binary -inputvalue $sum
}
## this will always subtract value2 from value1
function Get-BinaryDifference {
#  .ExternalHelp   Maml-PAMMath.XML
param(
    [string]$inputvalue1,
    [string]$inputvalue2
)
## check valid binary numbers
##  move this to a validation test
    Test-Binary $inputvalue1
    Test-Binary $inputvalue2

    $diff = (ConvertTo-Decimal -inputvalue $inputvalue1 -binary) - (ConvertTo-Decimal -inputvalue $inputvalue2 -binary)

    if ($diff -lt 0){Throw "Binary subtraction produces negative number"}
    else {ConvertTo-Binary -inputvalue $diff}
}

function Get-BinaryAND {
#  .ExternalHelp   Maml-PAMMath.XML
param(
    [string]$inputvalue1,
    [string]$inputvalue2,
    [switch]$showsum
)
    if ($inputvalue1.length -ne $inputvalue2.length){Throw "Input values must be same length"}

## check valid binary numbers
##  move this to a validation test
    Test-Binary $inputvalue1
    Test-Binary $inputvalue2

    $res = (ConvertTo-Decimal -inputvalue $inputvalue1 -binary) -band (ConvertTo-Decimal -inputvalue $inputvalue2 -binary)
    $ans = (ConvertTo-Binary -inputvalue $res).PadLeft($inputvalue1.length, "0")
    if ($showsum) {
        $inputvalue1
        $inputvalue2
        "-" * $inputvalue1.length
        $ans
    }
    else {
        $ans
    }
}

function Get-BinaryOR {
#  .ExternalHelp   Maml-PAMMath.XML
param(
    [string]$inputvalue1,
    [string]$inputvalue2,
    [switch]$showsum
)
    if ($inputvalue1.length -ne $inputvalue2.length){Throw "Input values must be same length"}

## check valid binary numbers
    Test-Binary $inputvalue1
    Test-Binary $inputvalue2

    $res = (ConvertTo-Decimal -inputvalue $inputvalue1 -binary) -bor (ConvertTo-Decimal -inputvalue $inputvalue2 -binary)
    
    $ans = (ConvertTo-Binary -inputvalue $res).PadLeft($inputvalue1.length, "0")
    if ($showsum) {
        $inputvalue1
        $inputvalue2
        "-" * $inputvalue1.length
        $ans
    }
    else {
        $ans
    }

}

function Get-BinaryXOR {
#  .ExternalHelp   Maml-PAMMath.XML
param(
    [string]$inputvalue1,
    [string]$inputvalue2,
    [switch]$showsum
)
    if ($inputvalue1.length -ne $inputvalue2.length){Throw "Input values must be same length"}

## check valid binary numbers
    Test-Binary $inputvalue1
    Test-Binary $inputvalue2

    $res = (ConvertTo-Decimal -inputvalue $inputvalue1 -binary) -bxor (ConvertTo-Decimal -inputvalue $inputvalue2 -binary)
    
    $ans = (ConvertTo-Binary -inputvalue $res).PadLeft($inputvalue1.length, "0")
    if ($showsum) {
        $inputvalue1
        $inputvalue2
        "-" * $inputvalue1.length
        $ans
    }
    else {
        $ans
    }

}
#########################################################################
#########################################################################
####
####  Hex Functions
####
#########################################################################
#########################################################################
function Get-HexSum {
#  .ExternalHelp   Maml-PAMMath.XML
param(
    [string]$inputvalue1,
    [string]$inputvalue2
)
## check valid hex numbers
    Test-Hex $inputvalue1
    Test-Hex $inputvalue2

    $sum = (ConvertTo-Decimal -inputvalue $inputvalue1 -hex) + (ConvertTo-Decimal -inputvalue $inputvalue2 -hex)

    ConvertTo-Hex -inputvalue $sum
}
## this will always subtract value2 from value1
function Get-HexDifference {
#  .ExternalHelp   Maml-PAMMath.XML
param(
    [string]$inputvalue1,
    [string]$inputvalue2
)
## check valid hex numbers
    Test-Hex $inputvalue1
    Test-Hex $inputvalue2

    $diff = (ConvertTo-Decimal -inputvalue $inputvalue1 -hex) - (ConvertTo-Decimal -inputvalue $inputvalue2 -hex)

    if ($diff -lt 0){Throw "Hex subtraction produces negative number"}
    else {ConvertTo-Hex -inputvalue $diff}
}