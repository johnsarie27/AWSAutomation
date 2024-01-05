function Copy-EC2Instance {
    <#
    .SYNOPSIS
        Copy EC2 Instance
    .DESCRIPTION
        Create copy of EC2 Instance based on existing instance. This will copy
        all relevant properties including specific tags, IAM profile, subnet,
        and security groups
    .PARAMETER EC2Instance
        EC2 Instance object to copy
    .PARAMETER Name
        Hostname of new EC2 Instance
    .PARAMETER Type
        Instance type for new EC2 Instance
    .PARAMETER AMIID
        AMI ID for new EC2 Instance
    .PARAMETER ProfileName
        AWS Profile Name
    .PARAMETER Credential
        AWS Credential Object
    .PARAMETER Region
        AWS region
    .INPUTS
        None.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Copy-EC2Instance -EC2Instance $ec2 -Name MyNewEC2 -Type m6i.large -AMIID $aid
        Makes a copy of EC2 Instance $ec2 with new name MyNewEC2 and type m61.large
    .NOTES
        Name:    Copy-EC2Instance
        Author:  Justin Johns
        Version: 0.1.4 | Last Edit: 2023-07-19
        - 0.1.4 - Added support for AWS Credential Profile
        - 0.1.3 - Code clean
        - 0.1.2 - Update comments
        - 0.1.0 - Initial version
        Comments: <Comment(s)>
        General notes
    #>
    [CmdletBinding(DefaultParameterSetName = '__pro')]
    Param(
        [Parameter(Mandatory, HelpMessage = 'EC2 Instance object to copy')]
        [ValidateNotNullOrEmpty()]
        [Amazon.EC2.Model.Instance] $EC2Instance,

        [Parameter(Mandatory, HelpMessage = 'Hostname for new EC2 Instance')]
        [ValidatePattern('[\w\.\-]{3,16}')]
        [System.String] $Name,

        [Parameter(Mandatory, HelpMessage = 'EC2 Instance type')]
        # Get-EC2InstanceType REQUIRES CREDENTIALS. THIS WILL FAIL BELOW IF
        # TYPE IS INVALID
        [ValidateNotNullOrEmpty()]
        [System.String] $Type,

        [Parameter(Mandatory, HelpMessage = 'AMI ID')]
        [ValidatePattern('ami-[0-9a-z]{17}')]
        [System.String] $AMIID,

        [Parameter(Mandatory, ParameterSetName = '__pro', HelpMessage = 'AWS Profile object')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [System.String] $ProfileName,

        [Parameter(Mandatory, ParameterSetName = '__crd', HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(Mandatory, HelpMessage = 'AWS region')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [System.String] $Region
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"
    }
    Process {
        # SET PARAMETERS FOR NEW SYSTEM
        #MetadataOptions_InstanceMetadataTag = [Amazon.EC2.InstanceMetadataTagsState]::new('Disabled')
        $instanceParams = @{
            Region                    = $Region
            ImageId                   = $AMIID
            MinCount                  = 1
            MaxCount                  = 1
            BlockDeviceMapping        = @(
                [Amazon.EC2.Model.BlockDeviceMapping] @{
                    DeviceName = '/dev/sda1'
                    Ebs        = [Amazon.EC2.Model.EbsBlockDevice] @{
                        VolumeType = 'gp3'
                        VolumeSize = 100
                        Encrypted  = $true
                    }
                }
                [Amazon.EC2.Model.BlockDeviceMapping] @{
                    DeviceName = 'xvdb'
                    Ebs        = [Amazon.EC2.Model.EbsBlockDevice] @{
                        VolumeType = 'gp3'
                        VolumeSize = 200
                        Encrypted  = $true
                    }
                }
            )
            InstanceType              = $Type
            SecurityGroupId           = $EC2Instance.SecurityGroups.GroupId
            SubnetId                  = $EC2Instance.SubnetId
            InstanceProfile_Name      = $EC2Instance.IamInstanceProfile.Arn.Split('/')[-1]
            EncodeUserData            = $true
            UserData                  = @(
                '<powershell>'
                'C:\ProgramData\Amazon\EC2-Windows\Launch\Scripts\InitializeDisks.ps1'
                "Rename-Computer -NewName $Name -Restart"
                '</powershell>'
            ) -join "`n"
            Monitoring                = $true
            Select                    = '*'
            MetadataOptions_HttpToken = [Amazon.EC2.HttpTokensState]::new('required')
            TagSpecification          = [Amazon.EC2.Model.TagSpecification] @{
                ResourceType = 'Instance'
                Tags         = @(
                    @{ Key = 'Name'; Value = $Name }
                    @{ Key = 'Patch Group'; Value = $EC2Instance.Tags.Where({ $_.Key -EQ 'Patch Group' }).Value }
                    @{ Key = 'Environment'; Value = $EC2Instance.Tags.Where({ $_.Key -EQ 'Environment' }).Value }
                    @{ Key = 'Project'; Value = $EC2Instance.Tags.Where({ $_.Key -EQ 'Project' }).Value }
                    @{ Key = 'BackupPlan'; Value = $EC2Instance.Tags.Where({ $_.Key -EQ 'BackupPlan' }).Value }
                    @{ Key = 'Product'; Value = $EC2Instance.Tags.Where({ $_.Key -EQ 'Product' }).Value }
                )
            }
        }

        # ADD CREDENTIALS
        if ($PSCmdlet.ParameterSetName -eq '__pro') { $instanceParams['ProfileName'] = $ProfileName }
        elseif ($PSCmdlet.ParameterSetName -eq '__crd') { $instanceParams['Credential'] = $Credential }

        # LAUNCH NEW EC2 INSTANCE
        New-EC2Instance @instanceParams
    }
}