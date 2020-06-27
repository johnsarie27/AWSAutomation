#Requires -Modules AWS.Tools.EC2

function Get-NetworkInfo {
    <# =========================================================================
    .SYNOPSIS
        Get AWS network infrastructure
    .DESCRIPTION
        This function iterates through the networking infrastructure (VPC's,
        Subnets, and Route Tables) and outputs a list of objects using the
        Route Tables as a connection point.
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
        PS C:\> Get-NetworkInfo -ProfileName $P $Region 'us-east-1' -VpcId vpc-12345678
        Get network infrastructure details for VPC vpc-12345678 in us-east-1 for store profile.
    .NOTES
        The output is not printable so I used the following code to format it:
            $Output = ""
            foreach ( $item in $list ) {
                $Output += $item | Select-Object Name, Id, VpcId | Out-String
                $Output += $item | Select-Object -EXP Routes | Out-String
                $Output += $item | Select-Object -EXP Subnets | Out-String
            }
            $Output
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = 'AWS Profile containing key and secret')]
        [ValidateScript({(Get-AWSCredential -ListProfileDetail).ProfileName -contains $_})]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(HelpMessage = 'AWS Region')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [string] $Region,

        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'VPC ID')]
        [ValidateScript({ $_ -match 'vpc-[a-z0-9]{8}' })]
        [string] $VpcId
    )

    $awsParams = @{
        Region = $Region
        Filter = @{Name = "vpc-id"; Values = $VpcId}
    }

    if ( $PSBoundParameters.ContainsKey('ProfileName') ) { $awsParams['ProfileName'] = $ProfileName }
    if ( $PSBoundParameters.ContainsKey('Credential') ) { $awsParams['Credential'] = $Credential }

    $routeTables = Get-EC2RouteTable @awsParams

    # CREATE NEW OBJECTS
    $list = [System.Collections.Generic.List[PSObject]]::new()
    foreach ( $rt in $routeTables ) {
        $new = @{
            Id      = $rt.RouteTableId
            Name    = ($rt.Tags.Where({$_.Key -EQ 'Name'})).Value
            VpcId   = $VpcId
            VpcCidr = (Get-EC2Vpc @awsParams).CidrBlock
        }

        # ADD ROUTE INFO
        $new.Routes = @()
        foreach ( $r in $rt.Routes ) {
            $Route = @{ Destination = $r.DestinationCidrBlock }
            if ( $null -ne $r.GatewayId ) { $Route.Gateway = $r.GatewayId } else { $Route.Gateway = '--' }
            if ( $null -ne $r.NatGatewayId ) { $Route.NatGateway = $r.NatGatewayId } else { $Route.NatGateway = '--' }
            if ( $null -ne $r.VpcPeeringConnectionId ) { $Route.VpcPX = $r.VpcPeeringConnectionId } else { $Route.VpcPX = '--' }
            $new.Routes += [PSCustomObject] $Route
        }
        # ADD SUBNET INFO
        $new['Subnets'] = [System.Collections.Generic.List[PSObject]]::new()
        foreach ( $a in $rt.Associations ) {
            $sn = Get-EC2Subnet @awsParams -SubnetId $a.SubnetId

            $assoc = @{
                SubnetId   = $a.SubnetId
                SubnetName = ($sn.Tags | Where-Object Key -EQ Name).Value
                SubnetAZ   = $sn.AvailabilityZone
                SubnetCidr = $sn.CidrBlock
            }

            # THIS REMOVES THE COLLECTION OF SUBNETS NOT ASSIGNED TO ANY ROUTE TABLE AND THEREFORE
            # ASSIGNED TO THE DEFAULT (MAIN) ROUTE TABLE
            if ( $sn.AvailabilityZone.Count -eq 1 ) { $new['Subnets'].Add([PSCustomObject] $assoc) }
            #$new.Subnets += [PSCustomObject] $assoc
        }
        # ADD IT TO THE LIST OF ROUTE TABLE OBJECTS
        $list.Add([PSCustomObject] $new)
    }
    # RETURN
    $list
}
