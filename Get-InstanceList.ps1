function Get-InstanceList {
    <# =========================================================================
    .SYNOPSIS
        Get list of EC2 instances
    .DESCRIPTION
        This function queries AWS EC2 API for all instances in a given region
        for a given account. It requires an AWS Credential Profile and uses a
        custom class to store the data.
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Region
        AWS region
    .INPUTS
        System.String.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Get-InstanceList -Region us-east-1 -ProfileName MyAccount
        Get a list of all EC2 instances in the AWS account represented by
        MyAccount in the us-east-1 region
    ========================================================================= #>
    [Alias('gil')]
    Param(
        [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'AWS Profile containing access key and secret')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [ValidateNotNullOrEmpty()]
        [Alias('Profile')]
        [string[]] $ProfileName,

        [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'AWS Region')]
        [ValidateSet('us-east-1','us-east-2','us-west-1','us-west-2')]
        [ValidateNotNullOrEmpty()]
        [string] $Region = 'us-east-1'
    )

    $IllegalChars = '(!|"|#|\$|%|&|''|\*|\+|,|:|;|\<|=|\>|\?|@|\[|\\|\]|\^|`|\{|\||\}|~)'

    if ( -not $PSBoundParameters.ContainsKey('ProfileName') ) {
        $ProfileName = Get-AWSCredential -ListProfileDetail | Select-Object -EXP ProfileName
    }

    $InstanceList = @()
    foreach ( $Name in $ProfileName ) {
        # GET ALL INSTANCES
        $EC2Instances = (Get-EC2Instance -ProfileName $Name -Region $Region).Instances

        # CREATE NEW OBJECTS
        foreach ( $ec2 in $EC2Instances ) {
            # GET NAME TAG AND ENVIRONMENT
            $nameTag = ( $ec2.Tags | Where-Object Key -ceq Name ).Value
            try {
                if ( $nameTag.Substring(3, 3) -match '^PRD$' ) { $envName = 'Production' }
                elseif ( $nameTag.Substring(3, 3) -match '^STG$' ) { $envName = 'Staging' }
                else { $envName = 'n/a' }
            }
            catch {
                $envName = 'n/a'
            }

            # CREATE OBJECT AND ADD PROPERTIES
            $new = New-Object EC2Instance #-TypeName EC2Instance
            $new.DR_Region = ( $ec2.Tags | Where-Object Key -eq DR_Region ).Value
            $new.Id = $ec2.InstanceId
            $new.Name = $nameTag
            $new.Environment = $envName
            $new.Type = $ec2.InstanceType.Value
            $new.Reserved = ( $ec2.Tags | Where-Object Key -eq RI_Candidate ).Value
            $new.AZ = $ec2.Placement.AvailabilityZone
            $new.PrivateIP = $ec2.PrivateIpAddress
            $new.PublicIP = $ec2.PublicIpAddress
            $new.AllPrivateIps = $ec2.NetworkInterfaces.PrivateIpAddresses.PrivateIpAddress
            $new.State = $ec2.State.Name.Value
            if ( $ec2.LaunchTime ) { $new.LastStart = $ec2.LaunchTime }
            $new.ProfileName = $Name
            $new.Region = $Region
            $new.GetDaysRunning()
            if ( $new.Name -match $IllegalChars ) { $new.IllegalName = $true }
            $new.NameTags = $ec2.Tags | Where-Object Key -EQ name | Select-Object -EXP Value
            $new.VpcId = $ec2.VpcId
            $new.SubnetId = $ec2.SubnetId
            $new.SecurityGroups = $ec2.SecurityGroups.GroupName
            $InstanceList += $new
        }
    }

    $InstanceList | Sort-Object -Property Name
}
