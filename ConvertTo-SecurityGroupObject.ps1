function ConvertTo-SecurityGroupObject {
    <# =========================================================================
    .SYNOPSIS
        Converts Security Groups to an object that can be used to populate a
        CloudFormation template.
    .DESCRIPTION
        This function takes an existing set of Security Groups contained in a
        VPC and outputs an object that can esily be converted into JSON for a
        CloudFormation template. 
    .EXAMPLE
        PS C:\> $a = ConvertTo-SecurityGroupObject -ProfileName $P -Region us-east-1 -VpcId $v
        PS C:\> $a | ConvertTo-Json -Depth 8
        This will create the JSON that can be edited to fit into a
        CloudFormation template.
    .INPUTS
        System.String
    .OUTPUTS
        System.Object
    .NOTES
        An object containing security group objects that can easitly be
        converted into JSON for a CloudFormation template.
        SecurityGroupEgress can be removed if desired. This will allow an
        egress object to be created allowing egress to any/all IPs.
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, HelpMessage = 'AWS Profile containing key and secret')]
        [ValidateScript( {(Get-AWSCredential -ListProfileDetail).ProfileName -contains $_})]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'AWS Region')]
        [ValidateSet('us-east-1', 'us-east-2', 'us-west-1', 'us-west-2')]
        [string] $Region = 'us-east-1',

        [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'VPC ID')]
        [ValidateScript( { $_ -match 'vpc-[a-z0-9]{8}' })]
        [string] $VpcId
    )

    Import-Module AWSPowerShell

    $ParamSplat = @{ ProfileName = $ProfileName ; Region = $Region }
    if ( $PSBoundParameters.ContainsKey('VpcId') ) {
        $ParamSplat.Filter = @{Name = "vpc-id"; Value = $VpcId}
    }

    # GET ALL SECURITY GROUPS FOR A GIVEN VPC
    $SecurityGroups = Get-EC2SecurityGroup @ParamSplat

    # CONVERT THOSE OBJECTS TO CUSTOM OBJECTS
    $MasterObject = New-Object -TypeName psobject
    
    foreach ( $sg in $SecurityGroups ) {
        
        $Name = $sg.GroupName
        $Object = [PSCustomObject] @{ Type = "AWS::EC2::SecurityGroup" }

        $Properties = [PSCustomObject] @{
            VpcId            = [PSCustomObject] @{ Ref = "rVpcMyApp" }
            GroupDescription = $sg.Description
            Tags             = $sg.Tag
        }
        $Object | Add-Member -MemberType NoteProperty -Name "Properties" -Value $Properties
        
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
            $SecurityGroupIngress += $SecurityGroup
        }
        $Properties | Add-Member -MemberType NoteProperty -Name "SecurityGroupIngress" -Value $SecurityGroupIngress
        
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
            $SecurityGroupEgress += $SecurityGroup
        }
        $Properties | Add-Member -MemberType NoteProperty -Name "SecurityGroupEgress" -Value $SecurityGroupEgress
        
        $MasterObject | Add-Member -MemberType NoteProperty -Name $Name -Value $Object
    }

    # RETURN MASTER OBJECT
    $MasterObject
}
