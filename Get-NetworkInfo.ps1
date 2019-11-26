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
            foreach ( $item in $List ) {
                $Output += $item | Select-Object Name, Id, VpcId | Out-String
                $Output += $item | Select-Object -EXP Routes | Out-String
                $Output += $item | Select-Object -EXP Subnets | Out-String
            }
            $Output
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, HelpMessage = 'AWS Profile containing key and secret')]
        [ValidateScript( {(Get-AWSCredential -ListProfileDetail).ProfileName -contains $_})]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'AWS Region')]
        [ValidateScript( { (Get-AWSRegion).Region -contains $_ })]
        [string] $Region = 'us-east-1',

        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'VPC ID')]
        [ValidateScript( { $_ -match 'vpc-[a-z0-9]{8}' })]
        [string] $VpcId
    )

    $ParamSplat = @{
        ProfileName = $ProfileName
        Region      = $Region
        Filter      = @{Name = "vpc-id"; Value = $VpcId}
    }

    $RouteTables = Get-EC2RouteTable @ParamSplat

    # CREATE NEW OBJECTS
    $List = @()
    foreach ( $rt in $RouteTables ) {
        $new = @{ Id = $rt.RouteTableId }
        $new.Name = ($rt.Tags | Where-Object Key -EQ Name).Value
        $new.VpcId = $VpcId
        $new.VpcCidr = Get-EC2Vpc @ParamSplat | Select-Object -EXP CidrBlock
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
        $new.Subnets = @()
        foreach ( $a in $rt.Associations ) {
            $SN = Get-EC2Subnet @ParamSplat -SubnetId $a.SubnetId
            $Assoc = @{ SubnetId = $a.SubnetId }
            $Assoc.SubnetName = ($SN.Tags | Where-Object Key -EQ Name).Value
            $Assoc.SubnetAZ = $SN.AvailabilityZone
            $Assoc.SubnetCidr = $SN.CidrBlock
            # THIS REMOVES THE COLLECTION OF SUBNETS NOT ASSIGNED TO ANY ROUTE TABLE AND THEREFORE
            # ASSIGNED TO THE DEFAULT (MAIN) ROUTE TABLE
            if ( $SN.AvailabilityZone.Count -eq 1 ) { $new.Subnets += [PSCustomObject] $Assoc }
            #$new.Subnets += [PSCustomObject] $Assoc
        }
        # ADD IT TO THE LIST OF ROUTE TABLE OBJECTS
        $List += [PSCustomObject] $new
    }
    # RETURN
    $List
}
