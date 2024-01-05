function Get-SecurityGroupInfo {
    <#
    .SYNOPSIS
        Retrieve security group information from an AWS VPC
    .DESCRIPTION
        This function retrieves all security groups from the provided VPC and
        outputs an object with a subset of the data, including the EC2
        instances, in a format easy to use
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Credential
        AWS Credential Object
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
    #>
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = 'AWS Profile containing key and secret')]
        [ValidateScript( {(Get-AWSCredential -ListProfileDetail).ProfileName -contains $_})]
        [System.String] $ProfileName,

        [Parameter(HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(HelpMessage = 'AWS Region')]
        [ValidateScript( { (Get-AWSRegion).Region -contains $_ })]
        [System.String] $Region,

        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'VPC ID')]
        [ValidateScript( { $_ -match 'vpc-[a-z0-9]{8}' })]
        [System.String] $VpcId
    )

    Begin {
        # SET API PARAMS
        $secGrpParams = @{
            Region = $Region
            Filter = @{Name = "vpc-id"; Values = $VpcId }
        }
        if ( $PSBoundParameters.ContainsKey('ProfileName') ) { $secGrpParams['ProfileName'] = $ProfileName }
        if ( $PSBoundParameters.ContainsKey('Credential') ) { $secGrpParams['Credential'] = $Credential }

        # MAKE API CALLS
        $securityGroups = Get-EC2SecurityGroup @secGrpParams
        $ec2 = (Get-EC2Instance @secGrpParams).Instances
        $sgRules = [System.Collections.Generic.List[System.Object]]::new()
        $propOrder = @('GroupId', 'GroupName', 'Description', 'RuleType', 'IpProtocol', 'FromPort', 'ToPort', 'CidrIp', 'Instances')
    }

    Process {
        # LOOP THROUGH SECURITY GROUPS
        foreach ( $sg in $securityGroups ) {
            # GENERIC LISTS
            $sgInstances = [System.Collections.Generic.List[System.Object]]::new()

            # ADD EC2 INSTANCES
            foreach ( $i in $ec2 ) {
                $nameTag = ($i.Tags | Where-Object Key -CEQ Name).Value
                if ( $i.SecurityGroups.GroupName -contains $sg.GroupName ) { $sgInstances.Add($nameTag) }
            }

            # CREATE SECURITY GROUP INGRESS
            foreach ( $IpPermissions in $sg.IpPermissions ) {
                $SecurityGroup = @{
                    #VpcId       = $sg.VpcId
                    GroupId     = $sg.GroupId
                    GroupName   = $sg.GroupName
                    Description = $sg.Description
                    RuleType    = 'Ingress'
                    IpProtocol  = $IpPermissions.IpProtocol
                    Instances   = $sgInstances -join ", "
                }

                if ( $IpPermissions.IpProtocol -ne -1 ) {
                    $SecurityGroup.FromPort = $IpPermissions.FromPort
                    $SecurityGroup.ToPort = $IpPermissions.ToPort
                }
                else {
                    $SecurityGroup.FromPort = "-1"
                    $SecurityGroup.ToPort = "-1"
                }
                <# if ( !$IpPermissions.Ipv4Ranges.CidrIp -and !$IpPermissions.Ipv6Ranges -and !$IpPermissions.IpvRanges ) {
                $SecurityGroup.CidrIp = "0.0.0.0/0"
                } #>
                $cidr = $null
                if ( $IpPermissions.Ipv4Ranges.CidrIp ) { $cidr = $IpPermissions.Ipv4Ranges.CidrIp }
                elseif ( $IpPermissions.Ipv6Ranges.CidrIp ) { $cidr = $IpPermissions.Ipv6Ranges.CidrIp }
                else { $cidr = $IpPermissions.IpRanges }

                if ( $cidr.GetType().BaseType.Name -eq 'Array' ) { $SecurityGroup.CidrIp = $cidr -join ", " }
                else { $SecurityGroup.CidrIp = $cidr }

                $sgRules.Add([PSCustomObject] $SecurityGroup)
            }

            # CREATE SECURITY GROUP EGRESS
            foreach ( $IpPermissions in $sg.IpPermissionsEgress ) {
                $SecurityGroup = @{
                    #VpcId       = $sg.VpcId
                    GroupId     = $sg.GroupId
                    GroupName   = $sg.GroupName
                    Description = $sg.Description
                    RuleType    = 'Egress'
                    IpProtocol  = $IpPermissions.IpProtocol
                    Instances   = $sgInstances -join ", "
                }

                if ( $IpPermissions.IpProtocol -ne -1 ) {
                    $SecurityGroup.FromPort = $IpPermissions.FromPort
                    $SecurityGroup.ToPort = $IpPermissions.ToPort
                }
                else {
                    $SecurityGroup.FromPort = "-1"
                    $SecurityGroup.ToPort = "-1"
                }
                <# if ( !$IpPermissions.Ipv4Ranges.CidrIp -and !$IpPermissions.Ipv6Ranges -and !$IpPermissions.IpvRanges ) {
                $SecurityGroup.CidrIp = "0.0.0.0/0"
                } #>
                $cidr = $null
                if ( $IpPermissions.Ipv4Ranges.CidrIp ) { $cidr = $IpPermissions.Ipv4Ranges.CidrIp }
                elseif ( $IpPermissions.Ipv6Ranges.CidrIp ) { $cidr = $IpPermissions.Ipv6Ranges.CidrIp }
                else { $cidr = $IpPermissions.IpRanges }

                if ( $cidr.GetType().BaseType.Name -eq 'Array' ) { $SecurityGroup.CidrIp = $cidr -join ", " }
                else { $SecurityGroup.CidrIp = $cidr }

                $sgRules.Add([PSCustomObject] $SecurityGroup)
            }
        }
    }

    End {
        # RETURN DATA
        $sgRules | Select-Object -Property $propOrder
    }
}
