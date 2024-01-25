function Get-WindowsDisk {
    <#
    .SYNOPSIS
        List the Windows disks
    .DESCRIPTION
        List the Windows disks
    .INPUTS
        None.
    .OUTPUTS
        System.Object[].
    .EXAMPLE
        PS C:\> Get-WindowsDisk
        Returns a mapping of the Windows disk(s) and associated EBS volume information
    .LINK
        https://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ec2-windows-volumes.html#windows-volume-mapping
    .NOTES
        General notes
        This function requires a default AWS Credential Profile or an IAM Instance
        Profile to be set with permissions for ec2:Describe*
        Several design choices were made for compatibility with PS 4.0
    #>

    Begin {
        function Get-EC2InstanceMetadata {
            param([string]$Path)
            (Invoke-WebRequest -Uri "http://169.254.169.254/latest/$Path").Content
        }

        function Convert-SCSITargetIdToDeviceName {
            param([int]$SCSITargetId)
            if ($SCSITargetId -eq 0) {
                return "sda1"
            }
            $deviceName = "xvd"
            if ($SCSITargetId -gt 25) {
                $deviceName += [char](0x60 + [int]($SCSITargetId / 26))
            }
            $deviceName += [char](0x61 + $SCSITargetId % 26)
            return $deviceName
        }
    }

    Process {
        try {
            $InstanceId = Get-EC2InstanceMetadata "meta-data/instance-id"
            $AZ = Get-EC2InstanceMetadata "meta-data/placement/availability-zone"
            $Region = $AZ.Remove($AZ.Length - 1)
            $BlockDeviceMappings = (Get-EC2Instance -Region $Region -Instance $InstanceId).Instances.BlockDeviceMappings
            $VirtualDeviceMap = @{ }
            (Get-EC2InstanceMetadata "meta-data/block-device-mapping").Split("`n") | ForEach-Object {
                $VirtualDevice = $_
                $BlockDeviceName = Get-EC2InstanceMetadata "meta-data/block-device-mapping/$VirtualDevice"
                $VirtualDeviceMap[$BlockDeviceName] = $VirtualDevice
                $VirtualDeviceMap[$VirtualDevice] = $BlockDeviceName
            }
        }
        catch {
            Write-Error -Message "Could not access the AWS API, therefore, VolumeId is not available. Verify that you provided your access keys."
        }

        foreach ( $d in (Get-Disk) ) {
            $DriveLetter = $null
            $VolumeName = $null

            $EbsVolumeID = $d.SerialNumber -replace "_[^ ]*$" -replace "vol", "vol-"
            Get-Partition -DiskId $d.Path | ForEach-Object {
                if ($d.DriveLetter -ne "") {
                    $DriveLetter = $d.DriveLetter
                    $VolumeName = (Get-PSDrive | Where-Object { $_.Name -eq $DriveLetter }).Description
                }
            }

            if ($d.path -like "*PROD_PVDISK*") {
                $BlockDeviceName = Convert-SCSITargetIdToDeviceName((Get-CimInstance -Class Win32_Diskdrive | Where-Object { $_.DeviceID -eq ("\\.\PHYSICALDRIVE" + $d.Number) }).SCSITargetId)
                $BlockDeviceName = "/dev/" + $BlockDeviceName
                $BlockDevice = $BlockDeviceMappings | Where-Object { $BlockDeviceName -like "*" + $_.DeviceName + "*" }
                $EbsVolumeID = $BlockDevice.Ebs.VolumeId
                $VirtualDevice = if ($VirtualDeviceMap.ContainsKey($BlockDeviceName)) { $VirtualDeviceMap[$BlockDeviceName] } else { $null }
            }
            elseif ($d.path -like "*PROD_AMAZON_EC2_NVME*") {
                $BlockDeviceName = Get-EC2InstanceMetadata "meta-data/block-device-mapping/ephemeral$((Get-CimInstance -Class Win32_Diskdrive | Where-Object {$_.DeviceID -eq ("\\.\PHYSICALDRIVE"+$d.Number) }).SCSIPort - 2)"
                $BlockDevice = $null
                $VirtualDevice = if ($VirtualDeviceMap.ContainsKey($BlockDeviceName)) { $VirtualDeviceMap[$BlockDeviceName] } else { $null }
            }
            elseif ($d.path -like "*PROD_AMAZON*") {
                $BlockDevice = ""
                $BlockDeviceName = ($BlockDeviceMappings | Where-Object { $_.ebs.VolumeId -eq $EbsVolumeID }).DeviceName
                $VirtualDevice = $null
            }
            else {
                $BlockDeviceName = $null
                $BlockDevice = $null
                $VirtualDevice = $null
            }

            New-Object PSObject -Property @{
                Disk          = $d.Number
                Partitions    = $d.NumberOfPartitions
                DriveLetter   = if ($null -eq $DriveLetter) { "N/A" } else { $DriveLetter }
                EbsVolumeId   = if ($null -eq $EbsVolumeID) { "N/A" } else { $EbsVolumeID }
                Device        = if ($null -eq $BlockDeviceName) { "N/A" } else { $BlockDeviceName }
                VirtualDevice = if ($null -eq $VirtualDevice) { "N/A" } else { $VirtualDevice }
                VolumeName    = if ($null -eq $VolumeName) { "N/A" } else { $VolumeName }
            }
        }
    }
}
