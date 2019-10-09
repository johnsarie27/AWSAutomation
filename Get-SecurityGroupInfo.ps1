#Requires -Module AWS.Tools.EC2

function Get-SecurityGroupInfo {
    <# =========================================================================
    .SYNOPSIS
        Retrieve security group information from an AWS VPC
    .DESCRIPTION
        This function retrieves all security groups from the provided VPC and
        outputs an object with a subset of the data, including the EC2
        instances, in a format easy to use
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Region
        AWS region
    .PARAMETER VpcId
        Id of an AWS VPC
    .INPUTS
        System.String. Get-SecurityGroupInfo accepts string values for all parameters
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> $a = Get-SecurityGroupInfo -ProfileName $P -VpcId $V
        Store all security groups from Profile $P and VPC $V in varibale $a
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, HelpMessage = 'AWS Profile containing key and secret')]
        [ValidateScript( {(Get-AWSCredential -ListProfileDetail).ProfileName -contains $_})]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'AWS Region')]
        [ValidateSet('us-east-1', 'us-east-2', 'us-west-1', 'us-west-2')]
        [string] $Region = 'us-east-1',

        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'VPC ID')]
        [ValidateScript( { $_ -match 'vpc-[a-z0-9]{8}' })]
        [string] $VpcId
    )

    $ParamSplat = @{ ProfileName = $ProfileName ; Region = $Region }
    $ParamSplat.Filter = @{Name = "vpc-id"; Value = $VpcId}

    # SECURITY GROUP INFO
    $SecurityGroups = Get-EC2SecurityGroup @ParamSplat
    $SGList = @()

    # INSTANCES WITH SECURITY GROUPS
    $EC2 = (Get-EC2Instance @ParamSplat).Instances

    foreach ( $sg in $SecurityGroups ) {
        $new = @{ GroupName = $sg.GroupName }
        $new.GroupId = $sg.GroupId
        $new.VpcId = $sg.VpcId
        $new.Description = $sg.Description

        # CREATE SECURITY GROUP INGRESS
        $SecurityGroupIngress = @()
        foreach ( $IpPermissions in $sg.IpPermissions ) {
            $SecurityGroup = @{ IpProtocol = $IpPermissions.IpProtocol }
            if ( $IpPermissions.IpProtocol -ne -1 ) {
                $SecurityGroup.FromPort = $IpPermissions.FromPort
                $SecurityGroup.ToPort = $IpPermissions.ToPort
            }
            <# if ( !$IpPermissions.Ipv4Ranges.CidrIp -and !$IpPermissions.Ipv6Ranges -and !$IpPermissions.IpvRanges ) {
                $SecurityGroup.CidrIp = "0.0.0.0/0"
            } #>
            if ( $IpPermissions.Ipv4Ranges.CidrIp ) { $SecurityGroup.CidrIp = $IpPermissions.Ipv4Ranges.CidrIp }
            elseif ( $IpPermissions.Ipv6Ranges.CidrIp ) { $SecurityGroup.CidrIp = $IpPermissions.Ipv6Ranges.CidrIp }
            else { $SecurityGroup.CidrIp = $IpPermissions.IpRanges }
            $SecurityGroupIngress += [PSCustomObject] $SecurityGroup
        }
        $new.IngressRules = $SecurityGroupIngress

        # CREATE SECURITY GROUP EGRESS
        $SecurityGroupEgress = @()
        foreach ( $IpPermissions in $sg.IpPermissionsEgress ) {
            $SecurityGroup = @{ IpProtocol = $IpPermissions.IpProtocol }
            if ( $IpPermissions.IpProtocol -ne -1 ) {
                $SecurityGroup.FromPort = $IpPermissions.FromPort
                $SecurityGroup.ToPort = $IpPermissions.ToPort
            }
            <# if ( !$IpPermissions.Ipv4Ranges.CidrIp -and !$IpPermissions.Ipv6Ranges -and !$IpPermissions.IpvRanges ) {
                $SecurityGroup.CidrIp = "0.0.0.0/0"
            } #>
            if ( $IpPermissions.Ipv4Ranges.CidrIp ) { $SecurityGroup.CidrIp = $IpPermissions.Ipv4Ranges.CidrIp }
            elseif ( $IpPermissions.Ipv6Ranges.CidrIp ) { $SecurityGroup.CidrIp = $IpPermissions.Ipv6Ranges.CidrIp }
            else { $SecurityGroup.CidrIp = $IpPermissions.IpRanges }
            $SecurityGroupEgress += [PSCustomObject] $SecurityGroup
        }
        $new.EgressRules = $SecurityGroupEgress

        # ADD EC2 INSTANCES
        $new.InstanceNames = @()
        foreach ( $i in $EC2 ) {
            $InstanceName = ($i.Tags | Where-Object Key -EQ Name).Value
            if ( $i.SecurityGroups.GroupName -contains $sg.GroupName ) { $new.InstanceNames += $InstanceName }
        }

        $SGList += [PSCustomObject] $new
    }

    $SGList
}
