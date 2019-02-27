function Get-AvailableEBS {
    <# =========================================================================
    .SYNOPSIS
        Get "unattached" Elastic Block Store volumes
    .DESCRIPTION
        This function returns a list of custom objects with properties from AWS
        EBS volume objects where each EBS volume is available (unattached).
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Region
        AWS region
    .PARAMETER AllProfiles
        Pull data from all available AWS Credential Profiles.
    .INPUTS
        System.String.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Get-AvailableEBS -AllProfiles | Group -Property Account | Select Name, Count
        Get unattached EBS volumes, group them by Account, and display Name and Count
    ========================================================================= #>
    [CmdletBinding(DefaultParameterSetName = 'all')]
    Param(
        [Parameter(Mandatory, ParameterSetName = 'targeted', HelpMessage = 'AWS Credential Profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [Alias('Profile', 'Name')]
        [string[]] $ProfileName,

        [Parameter(HelpMessage = 'Name of desired AWS Region.')]
        [ValidateSet('us-east-1','us-east-2','us-west-1','us-west-2')]
        [String] $Region = 'us-east-1',

        [Parameter(Mandatory, ParameterSetName = 'all', HelpMessage = 'All available AWS Credential Profiles')]
        [Alias('All')]
        [switch] $AllProfiles
    )

    # GET PROFILE LIST
    if ( $PSBoundParameters.ContainsKey('ProfileName') ) { $ProfileList = $ProfileName }
    if ( $PSBoundParameters.ContainsKey('AllProfiles') ) {
        $ProfileList = Get-AWSCredential -ListProfileDetail | Select-Object -ExpandProperty ProfileName
    }

    $AllVolumes = @() ; $Date = Get-Date
    foreach ( $name in $ProfileList ) {
        # GET ALL AVAILABLE VOLUMES
        $VolumeList = Get-EC2Volume -Filter @{Name="status";Values="available"} -ProfileName $name -Region $Region

        foreach ( $volume in $VolumeList ) {
            # CREATE NEW OBJECT AND ADD PROPERTIES
            $New = New-Object -TypeName psobject
            $New | Add-Member -MemberType NoteProperty -Name Id -Value $volume.VolumeId
            $New | Add-Member -MemberType NoteProperty -Name Account -Value $name
            $New | Add-Member -MemberType NoteProperty -Name CreateTime -Value $volume.CreateTime
            $New | Add-Member -MemberType NoteProperty -Name Status -Value $volume.Status
            $New | Add-Member -MemberType NoteProperty -Name Encrypted -Value $volume.Encrypted
            $New | Add-Member -MemberType NoteProperty -Name AvailabilityZone -Value $volume.AvailabilityZone
            $New | Add-Member -MemberType NoteProperty -Name Iops -Value $volume.Iops
            if ( $volume.KmsKeyId ) { $Key = $volume.KmsKeyId } else { $Key = $null }
            $New | Add-Member -MemberType NoteProperty -Name KmsKeyId -Value $Key
            $New | Add-Member -MemberType NoteProperty -Name Size -Value $volume.Size
            $New | Add-Member -MemberType NoteProperty -Name SnapshotId -Value $volume.SnapshotId
            $New | Add-Member -MemberType NoteProperty -Name Tags -Value $volume.Tags
            $New | Add-Member -MemberType NoteProperty -Name VolumeType -Value $volume.VolumeType
            $Age = New-TimeSpan -Start $volume.CreateTime -End $Date
            $New | Add-Member -MemberType NoteProperty -Name AgeInDays -Value $Age.Days

            $AllVolumes += $New
        }

        # CLEAR LIST
        $VolumeList = $null
    }

    # RETURN LIST
    $AllVolumes
}
