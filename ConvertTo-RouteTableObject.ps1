function ConvertTo-RouteTableObject {
    <# =========================================================================
    .SYNOPSIS
        Converts Route Tables to an object that can be used to populate a
        CloudFormation template.
    .DESCRIPTION
        This function takes an existing set of Route Tables contained in an AWS
        account and outputs an object that can esily be converted into JSON for
        a CloudFormation template. 
    .EXAMPLE
        PS C:\> $a = ConvertTo-RouteTableObject -ProfileName $P -Region us-east-1
        PS C:\> $a | ConvertTo-Json -Depth 8
        This will create the JSON that can be edited to fit into a
        CloudFormation template.
    .INPUTS
        ProfileName = AWS Credential Profile
        Region = AWS Region
    .OUTPUTS
        An object containing route table and route object(s) that can easitly
        be converted into JSON for a CloudFormation template.
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, HelpMessage = 'AWS Profile containing key and secret')]
        [ValidateScript( {(Get-AWSCredential -ListProfileDetail).ProfileName -contains $_})]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'AWS Region')]
        [ValidateSet('us-east-1', 'us-east-2', 'us-west-1', 'us-west-2')]
        [string] $Region = 'us-east-1',

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, HelpMessage = 'VPC ID')]
        [ValidateScript( { $_ -match 'vpc-[a-z0-9]{8}' })]
        [string] $VpcId
    )
    
    Import-Module -Name AWSPowerShell

    $ParamSplat = @{
        ProfileName = $ProfileName
        Region      = $Region
        Filter      = @{Name = "vpc-id"; Value = $VpcId}
    }
    
    $RouteTables = Get-EC2Subnet @ParamSplat
    $MasterObject = New-Object -TypeName psobject

    foreach ( $rt in $RouteTables ) {
        # GET SUBNET NAME
        $Name = $rt.Tags | Where-Object Key -EQ Name | Select-Object -EXP Value
        if ( !$Name ) { $Name = $rt.RouteTableId.Replace("-", "") }
        $Object = [PSCustomObject] @{ Type = "AWS::EC2::RouteTable" }

        $Properties = [PSCustomObject] @{
            VpcId = $rt.VpcId
            Tags  = $rt.Tags
        }
        
        # ADD ROUTETABLE OBJECT TO MASTER OBJECT
        $Object | Add-Member -MemberType NoteProperty -Name "Properties" -Value $Properties
        $MasterObject | Add-Member -MemberType NoteProperty -Name $Name -Value $Object

        # ======================================================================
        # ADD ROUTES
        $i = 0
        foreach ( $route in $rt.Routes ) {
            $RouteName = ("Route{0}" -f $i.ToString("00"))
            $RouteObject = [PSCustomObject] @{ Type = "AWS::EC2::Route" }

            $RouteProperties = [PSCustomObject] @{ RouteTableId = [PSCustomObject] @{ Ref = $Name } }
            if ( $route.DestinationCidrBlock ) {
                $RouteProperties | Add-Member -MemberType NoteProperty -Name DestinationCidrBlock -Value $route.DestinationCidrBlock
            }
            else { $RouteProperties | Add-Member -MemberType NoteProperty -Name DestinationPrefixListId -Value $route.DestinationPrefixListId }
            if ( $route.NatGatewayId ) {
                $RouteProperties | Add-Member -MemberType NoteProperty -Name NatGatewayId -Value $route.NatGatewayId
                $MasterObject | Add-Member -MemberType NoteProperty -Name rEIP -Value (New-ResourceObject -EIP)
                $MasterObject | Add-Member -MemberType NoteProperty -Name rNATGateway (New-ReousrceObject -NGW -EipName rEIP -SubnetName rDmzSubnet)
                ## SEE IF THERE'S A NAT GATEWAY OBJECT IN AWSPOWERSHELL AND PULL SUBNET NAME FROM THAT?
                ## $NGWs = Get-EC2NatGateway @ParamSplat ; $NGWs.SubnetId
            }
            if ( $route.GatewayId ) {
                $RouteProperties | Add-Member -MemberType NoteProperty -Name GatewayId -Value $route.GatewayId
                $MasterObject | Add-Member -MemberType NoteProperty -Name rInternetGateway -Value (New-ResourceObject -IGW -NameTag "igw$VpcId")
                $MasterObject | Add-Member -MemberType NoteProperty -Name rAttachGateway -Value (New-ResourceObject -VGA)
            }
            if ( $route.VpcPeeringConnectionId ) {
                $RouteProperties | Add-Member -MemberType NoteProperty -Name VpcPeeringConnectionId -Value $route.VpcPeeringConnectionId
            }

            $RouteObject | Add-Member -MemberType NoteProperty -Name "Properties" -Value $RouteProperties
            $MasterObject | Add-Member -MemberType NoteProperty -Name $RouteName -Value $RouteObject
        }
        # ======================================================================

    }
    # RETURN MASTER OBJECT
    $MasterObject
}
