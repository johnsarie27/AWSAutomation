#Requires -Modules AWS.Tools.EC2

function Get-AvailableEBS {
    <# =========================================================================
    .SYNOPSIS
        Get "unattached" Elastic Block Store volumes
    .DESCRIPTION
        This function returns a list of custom objects with properties from AWS
        EBS volume objects where each EBS volume is available (unattached).
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Credential
        AWS Credential Object
    .PARAMETER Region
        AWS region
    .INPUTS
        System.String.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Get-AvailableEBS -AllProfiles | Group -Property Account | Select Name, Count
        Get unattached EBS volumes, group them by Account, and display Name and Count
    ========================================================================= #>
    [CmdletBinding(DefaultParameterSetName = '_profile')]
    [OutputType([System.Object[]])]

    Param(
        [Parameter(Mandatory, ParameterSetName = '_profile', HelpMessage = 'AWS Credential Profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string[]] $ProfileName,

        [Parameter(Mandatory, ParameterSetName = '_credential', HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials[]] $Credential,

        [Parameter(HelpMessage = 'Name of desired AWS Region.')]
        [ValidateScript( { (Get-AWSRegion).Region -contains $_ })]
        [String] $Region = 'us-east-1'
    )

    Begin {
        function New-EbsVolume ([System.Object] $volume, [string] $account) {
            $new = New-Object -TypeName psobject
            $new | Add-Member -MemberType NoteProperty -Name Id -Value $volume.VolumeId
            $new | Add-Member -MemberType NoteProperty -Name Account -Value $account
            $new | Add-Member -MemberType NoteProperty -Name CreateTime -Value $volume.CreateTime
            $new | Add-Member -MemberType NoteProperty -Name Status -Value $volume.Status
            $new | Add-Member -MemberType NoteProperty -Name Encrypted -Value $volume.Encrypted
            $new | Add-Member -MemberType NoteProperty -Name AvailabilityZone -Value $volume.AvailabilityZone
            $new | Add-Member -MemberType NoteProperty -Name Iops -Value $volume.Iops
            if ( $volume.KmsKeyId ) { $Key = $volume.KmsKeyId } else { $Key = $null }
            $new | Add-Member -MemberType NoteProperty -Name KmsKeyId -Value $Key
            $new | Add-Member -MemberType NoteProperty -Name Size -Value $volume.Size
            $new | Add-Member -MemberType NoteProperty -Name SnapshotId -Value $volume.SnapshotId
            $new | Add-Member -MemberType NoteProperty -Name Tags -Value $volume.Tags
            $new | Add-Member -MemberType NoteProperty -Name VolumeType -Value $volume.VolumeType
            $new | Add-Member -MemberType NoteProperty -Name AgeInDays -Value (New-TimeSpan -Start $volume.CreateTime -End $date).Days

            $new
        }

        $date = Get-Date
        $results = [System.Collections.Generic.List[System.Object]]::new()

        $awsParams = @{ Region = $Region; Filter = @{Name = "status";Values = "available"} }
    }

    Process {
        if ( $PSCmdlet.ParameterSetName -eq '_profile' ) {
            foreach ( $name in $ProfileName ) {
                foreach ( $volume in (Get-EC2Volume -ProfileName $name @awsParams) ) {
                    # CREATE NEW OBJECT AND ADD TO RESULTS
                    $results.Add((New-EbsVolume $volume $name))
                }
            }
        }
        if ( $PSCmdlet.ParameterSetName -eq '_credential' ) {
            foreach ( $cred in $Credential ) {
                foreach ( $volume in (Get-EC2Volume -Credential $cred @awsParams) ) {
                    # CREATE NEW OBJECT AND ADD TO RESULTS
                    $results.Add((New-EbsVolume $volume 'UNKNOWN'))
                }
            }
        }
    }

    End {
        Write-Verbose -Message ('Number of volumes: [{0}]' -f $results.Count)
        # RETURN LIST
        $results
    }
}
