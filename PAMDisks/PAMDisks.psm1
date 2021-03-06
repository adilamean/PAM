#Requires -version 2.0
##
##  Author Richard Siddaway
##    Version 0.1 - Inital Release  July 2010
###############################################
##
##  Contents
##      Get-Disk - returns information on the physical disks
##      Get-LogicalDisk - returns information on logical 
##      Get-CDdrive - returns info on installed CD drives
##      Get-DiskRelationship - returns relationship between 
##                             physical, logical and partitions  
##      Get-MountPoint - returns Mount Points
##      Get-MappedDrive - returns mapped drives
##
#########################################################################
#########################################################################
####
####  Code Translation Tables
####
#########################################################################
#########################################################################
## Configuration Manager Error Code
$cmec = DATA {
ConvertFrom-StringData -StringData @'
0 = Device is working properly.
1 = Device is not configured correctly.
2 = Windows cannot load the driver for this device.
3 = Driver for this device might be corrupted, or the system may be low on memory or other resources.
4 = Device is not working properly. One of its drivers or the registry might be corrupted.
5 = Driver for the device requires a resource that Windows cannot manage.
6 = Boot configuration for the device conflicts with other devices.
7 = Cannot filter.
8 = Driver loader for the device is missing.
9 = Device is not working properly. The controlling firmware is incorrectly reporting the resources for the device.
10 = Device cannot start.
11 = Device failed. 
12 = Device cannot find enough free resources to use. 
13 = Windows cannot verify the device's resources. 
14 = Device cannot work properly until the computer is restarted. 
15 = Device is not working properly due to a possible re-enumeration problem. 
16 = Windows cannot identify all of the resources that the device uses. 
17 = Device is requesting an unknown resource type. 
18 = Device drivers must be reinstalled.
19 = Failure using the VxD loader. 
20 = Registry might be corrupted. 
21 = System failure. If changing the device driver is ineffective, see the hardware documentation. Windows is removing the device.
22 = Device is disabled. 
23 = System failure. If changing the device driver is ineffective, see the hardware documentation. 
24 = Device is not present, not working properly, or does not have all of its drivers installed. 
25 = Windows is still setting up the device. 
26 = Windows is still setting up the device. 
27 = Device does not have valid log configuration. 
28 = Device drivers are not installed. 
29 = Device is disabled. The device firmware did not provide the required resources. 
30 = Device is using an IRQ resource that another device is using. 
31 = Device is not working properly. Windows cannot load the required device drivers.
'@
}
## disk type
$dtype = DATA {
ConvertFrom-StringData -StringData @'
0 = Unknown
1 = No Root Directory
2 = Removable Disk
3 = Local Disk
4 = Network Drive
5 = Compact Disk
6 = RAM Disk
'@
}
## media type
$media = DATA {
ConvertFrom-StringData -StringData @'
11 = Removable media other than floppy
12 = Fixed hard disk media
'@
}
#########################################################################
#########################################################################
####
####  Functions
####
#########################################################################
#########################################################################
function Get-Disk {
param (
    [string]$computername = "localhost"
)
    Get-WmiObject -Class Win32_DiskDrive -ComputerName $computername | 
    Format-List DeviceID, Status, 
    @{Name="Configuration Manager Error Code"; Expression={$cmec["$($_.ConfigManagerErrorCode)"]}},
    Index, InterfaceType, 
    Partitions, BytesPerSector, SectorsPerTrack, TracksPerCylinder,
    TotalHeads, TotalCylinders, TotalTracks, TotalSectors,
    @{Name="Disk Size (GB)"; Expression={"{0:F3}" -f $($_.Size/1GB)}}
}
function Get-LogicalDisk {
param (
    [string]$computername = "localhost"
)
	Get-WmiObject -Class Win32_LogicalDisk -ComputerName $computername | 
	Format-List DeviceID, Compressed, Description,
	@{Name="Drive Type"; Expression={$dtype["$($_.DriveType)"]}},
	@{Name="Media Type"; Expression={$media["$($_.MediaType)"]}},
	FileSystem, 
	@{Name="Disk Size (GB)"; Expression={"{0:F3}" -f $($_.Size/1GB)}},
	@{Name="Free Space (GB)"; Expression={"{0:F3}" -f $($_.FreeSpace/1GB)}},
	SupportsDiskQuotas,
	SupportsFileBasedCompression,
	VolumeName,
	VolumeSerialNumber
}
function Get-DiskRelationship {
param (
    [string]$computername = "localhost"
)
    Get-WmiObject -Class Win32_DiskDrive -ComputerName $computername | foreach {
        "`n {0} {1}" -f $($_.Name), $($_.Model)

        $query = "ASSOCIATORS OF {Win32_DiskDrive.DeviceID='" `
         + $_.DeviceID + "'} WHERE ResultClass=Win32_DiskPartition"
         
        Get-WmiObject -Query $query -ComputerName $computername | foreach {
            ""
            "Name             : {0}" -f $_.Name
            "Description      : {0}" -f $_.Description
            "PrimaryPartition : {0}" -f $_.PrimaryPartition
        
            $query2 = "ASSOCIATORS OF {Win32_DiskPartition.DeviceID='" `
            + $_.DeviceID + "'} WHERE ResultClass=Win32_LogicalDisk"
                
            Get-WmiObject -Query $query2 -ComputerName $computername | Format-List Name,
            @{Name="Disk Size (GB)"; Expression={"{0:F3}" -f $($_.Size/1GB)}},
            @{Name="Free Space (GB)"; Expression={"{0:F3}" -f $($_.FreeSpace/1GB)}}
        
        }
    }
}
function Get-MountPoint {
param (
    [string]$computername = "localhost"
)
    Get-WmiObject -Class Win32_MountPoint -ComputerName $computername | 
    where {$_.Directory -like 'Win32_Directory.Name="C:\\Data*"'} | 
    foreach {
        $vol = $_.Volume
        Get-WmiObject -Class Win32_Volume -ComputerName $computername | where {$_.__RELPATH -eq $vol} | 
        Select @{Name="Folder"; Expression={$_.Caption}}, 
        @{Name="Size (GB)"; Expression={"{0:F3}" -f $($_.Capacity / 1GB)}},
        @{Name="Free (GB)"; Expression={"{0:F3}" -f $($_.FreeSpace / 1GB)}},
        @{Name="%Free"; Expression={"{0:F2}" -f $(($_.FreeSpace/$_.Capacity)*100)}}
    }
}
function Get-CDdrive {
param (
    [string]$computername = "localhost"
)
    $cds = Get-WmiObject -Class Win32_CDROMDrive -ComputerName $computername
    foreach ($cd in $cds){
        $cd | select Caption, Drive, MediaLoaded, Status, CompressionMethod,
        Manufacturer, MediaType,
        SCSIBus, SCSILogicalUnit, SCSIPort, SCSITargetId,
        TransferRate
        "Capabilities:"
        $cd | select -ExpandProperty CapabilityDescriptions 
        "`n"
    }
}
function Get-MappedDrive {
param (
    [string]$computername = "localhost"
)
    Get-WmiObject -Class Win32_MappedLogicalDisk -ComputerName $computername | 
    Format-List DeviceId, VolumeName, SessionID, Size, FreeSpace 
}