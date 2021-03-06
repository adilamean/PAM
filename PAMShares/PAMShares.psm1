#Requires -version 2.0
##
##  Author Richard Siddaway
##    Version 0.1 - Inital Release  April 2010
##    Version 0.2 - June 2010
##       Added wildcard option to Get-Share
##       Changed parameter order on New-Share
##         to be share, path as Net Share         
###############################################
function Get-Share {
#  .ExternalHelp   Maml-PAMShares.XML
param (
    [string]$name
)    
    $name = $name -replace "\*","%"
    if (!$name) {Get-WmiObject -Class Win32_Share}
    else {Get-WmiObject -Class Win32_Share -Filter "Name LIKE '$name'"}
}

function New-Share {
#  .ExternalHelp   Maml-PAMShares.XML
[CmdletBinding(SupportsShouldProcess=$True)]
param (
    [string]$name,
    [string]$path,
    [int][ValidateRange(0,2)]$type,
    [int]$maxcon,
    [string]$desc
)

$fail = DATA {
ConvertFrom-StringData -StringData @'
0 =  Success 
2 =  Access Denied 
8 =  Unknown Failure 
9 = Invalid Name 
10 =  Invalid Level 
21 =  Invalid Parameter 
22 =  Duplicate Share 
23 =  Redirected Path 
24 =  Unknown Device or Directory 
25 =  Net Name Not Found
'@
}

    if (!(Test-Path -Path $path)){Throw "Folder does not exist"}
    $s = [WmiClass]"Win32_Share" 
    $ret = $s.Create($path, $name, $type, $maxcon, $desc)
    if ($ret.ReturnValue -ne 0){
        Write-Host "Share $name was not created"
        Write-Host "Failure reason: $($fail["$($ret.ReturnValue)"])"
    }
    else {Write-Host "Share $name was created"}
}

function Remove-Share {
#  .ExternalHelp   Maml-PAMShares.XML
param (
    [string]$name
)    
    Get-WmiObject -Class Win32_Share -Filter "Name='$name'" |
    Remove-WmiObject
}

function Set-Share {
#  .ExternalHelp   Maml-PAMShares.XML
[CmdletBinding(SupportsShouldProcess=$True)]
param (
    [string]$name,
    [int]$maxcon,
    [string]$desc
)    
    $share = Get-WmiObject -Class Win32_Share -Filter "Name='$name'" 
    if (!$maxcon){$maxcon = $share.MaximumAllowed }
    if (!$desc){$desc = $share.Description}
    
    $share.SetShareInfo($maxcon, $desc, $null)

}

$mask = DATA {
ConvertFrom-StringData -StringData @'
1 = Grants the right to read data from the file. For a directory, this value grants the right to list the contents of the directory.
2 = Grants the right to write data to the file. For a directory, this value grants the right to create a file in the directory.
4 = Grants the right to append data to the file. For a directory, this value grants the right to create a subdirectory.
8 = Grants the right to read extended attributes.
16 = Grants the right to write extended attributes.
32 = Grants the right to execute a file. For a directory, the directory can be traversed.
64 = Grants the right to delete a directory and all of the files it contains (its children), even if the files are read-only.
128 = Grants the right to read file attributes.
256 = Grants the right to change file attributes.
65536 = Grants delete access.
131072 = Grants read access to the security descriptor and owner.
262144 = Grants write access to the discretionary access control list (DACL).
524288 = Assigns the write owner.
1048576 = Synchronizes access and allows a process to wait for an object to enter the signaled state. 
'@
}

function Get-ShareAccessMask {
#  .ExternalHelp   Maml-PAMShares.XML
[CmdletBinding(SupportsShouldProcess=$True)]
param (
    [string]$name
)    
    $share = Get-WmiObject -Class Win32_Share -Filter "Name='$name'" 
    $ret = (Invoke-WmiMethod -InputObject $share -Name GetAccessMask).ReturnValue
    
    ## now we need to unravel the rights
    $mask.GetEnumerator()| sort Key | foreach {
        #$_.key
        if ($ret -band $_.key){
            "$($mask[$($_.key)])"
        }
    
    }
} 

function Get-ShareSecurity {
#  .ExternalHelp   Maml-PAMShares.XML
    Get-WmiObject -Class Win32_LogicalShareAccess |
    foreach {
       $name = ($_.SecuritySetting -split "=")[1]
       $sid = (($_.Trustee -split "=")[1]).Replace('"','')
       $AccessMask = $_.AccessMask
       
       $query =  "ASSOCIATORS OF {Win32_SID.SID='" `
       + $sid + "'} WHERE ResultClass=Win32_SystemAccount"
       
       $trustee = Get-WmiObject -Query $query 
       
       if($trustee -eq $null){
            $query =  "ASSOCIATORS OF {Win32_SID.SID='" `
            + $sid + "'} WHERE ResultClass=Win32_UserAccount"
            #$query
            $trustee = Get-WmiObject -Query $query 
       }
       
       if($trustee -eq $null){
            $query =  "ASSOCIATORS OF {Win32_SID.SID='" `
            + $sid + "'} WHERE ResultClass=Win32_Group"
             $trustee = Get-WmiObject -Query $query 
       }
       
       "`nSHARE: $name   USER: $($trustee.Caption)  RIGHTS:"
       ## now we need to unravel the rights
        $mask.GetEnumerator()| sort Key | 
        foreach {
            if ($AccessMask -band $_.key){"$($mask[$($_.key)])"}
        }
       
    }
}  

Export-ModuleMember -Function Get-Share, New-Share, Remove-Share, Set-Share, Get-ShareAccessMask, Get-ShareSecurity