function New-Instance {
    <# =========================================================================
    .SYNOPSIS
        Create new EC2 Instance object
    .DESCRIPTION
        Create new EC2 Instance object with easy to access properties
    .PARAMETER Instance
        One or more AWS EC2 Instance objects
    .INPUTS
        None.
    .OUTPUTS
        EC2Instance.
    .EXAMPLE
        PS C:\> New-Instance -Instance (Get-EC2Instance).Instances
        Create a new EC2Instance object from all AWS objects
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, Position = 0, HelpMessage = 'EC2 Instance object(s)')]
        [AllowNull()]
        [AllowEmptyString()]
        [Amazon.EC2.Model.Instance[]] $Instance
    )

    Begin {
        # THESE CHARACTERS CAUSE PROBLEMS IF FOUND IN THE NAME TAG OR AN EC2 INSTANCE
        $illegalChars = '(!|"|#|\$|%|&|''|\*|\+|,|:|;|\<|=|\>|\?|@|\[|\\|\]|\^|`|\{|\||\}|~)'

        # CREATE ARRAY
        $instanceList = [System.Collections.Generic.List[System.Object]]::new()
    }

    Process {
        # CREATE NEW OBJECTS
        foreach ( $ec2 in $Instance ) {
            # CREATE OBJECT AND ADD PROPERTIES
            #[EC2Instance]$new = [EC2Instance]::new()
            $new = New-Object -TypeName EC2Instance
            $new.DR_Region = ($ec2.Tags | Where-Object Key -eq DR_Region).Value
            $new.Id = $ec2.InstanceId
            $new.Name = ($ec2.Tags | Where-Object Key -ceq Name).Value
            $new.GetEnvironment()
            $new.Type = $ec2.InstanceType.Value
            $new.Reserved = ($ec2.Tags | Where-Object Key -eq RI_Candidate).Value
            $new.AZ = $ec2.Placement.AvailabilityZone
            $new.PrivateIP = $ec2.PrivateIpAddress
            $new.PublicIP = $ec2.PublicIpAddress
            $new.AllPrivateIps = $ec2.NetworkInterfaces.PrivateIpAddresses.PrivateIpAddress
            $new.State = $ec2.State.Name.Value
            if ( $ec2.LaunchTime ) { $new.LastStart = $ec2.LaunchTime }
            $new.ProfileName = $name
            $new.Region = $Region
            $new.GetDaysRunning()
            if ( $new.Name -match $illegalChars ) { $new.IllegalName = $true }
            $new.NameTags = ($ec2.Tags | Where-Object Key -EQ name).Value
            $new.VpcId = $ec2.VpcId
            $new.SubnetId = $ec2.SubnetId
            $new.SecurityGroups = $ec2.SecurityGroups.GroupName

            $instanceList.Add($new)
        }
    }

    End {
        # RETURN ARRAY
        $instanceList
    }
}
