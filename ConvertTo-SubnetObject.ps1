#Requires -Modules 'AWS.Tools.EC2'

function ConvertTo-SubnetObject {
    <# =========================================================================
    .SYNOPSIS
        Converts Subnets to an object that can be used to populate a
        CloudFormation template.
    .DESCRIPTION
        This function takes an existing set of Subnets contained in an AWS
        account and outputs an object that can esily be converted into JSON for
        a CloudFormation template.
    .EXAMPLE
        PS C:\> $a = ConvertTo-SubnetObject -ProfileName $P -Region us-east-1
        PS C:\> $a | ConvertTo-Json -Depth 8
        This will create the JSON that can be edited to fit into a
        CloudFormation template.
    .INPUTS
        System.String
    .OUTPUTS
        System.Object
    .NOTES
        An object containing subnet object(s) that can easitly be converted into
        JSON for a CloudFormation template.
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, HelpMessage = 'AWS Profile containing key and secret')]
        [ValidateScript( {(Get-AWSCredential -ListProfileDetail).ProfileName -contains $_})]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'AWS Region')]
        [ValidateScript( { (Get-AWSRegion).Region -contains $_ })]
        [string] $Region = 'us-east-1',

        [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'VPC ID')]
        [ValidateScript( { $_ -match 'vpc-[a-z0-9]{8}' })]
        [string] $VpcId
    )

    $ParamSplat = @{ ProfileName = $ProfileName ; Region = $Region }
    if ( $PSBoundParameters.ContainsKey('VpcId') ) {
        $ParamSplat.Filter = @{Name = "vpc-id"; Value = $VpcId}
    }

    $Subnets = Get-EC2Subnet @ParamSplat
    $MasterObject = New-Object -TypeName psobject

    foreach ( $subnet in $Subnets ) {
        # GET SUBNET NAME
        $Name = $subnet.Tags | Where-Object Key -EQ Name | Select-Object -EXP Value
        if ( !$Name ) { $Name = $subnet.SubnetId.Replace("-", "") }
        $Object = [PSCustomObject] @{ Type = "AWS::EC2::Subnet" }

        $Properties = [PSCustomObject] @{
            CidrBlock        = $subnet.CidrBlock
            AvailabilityZone = $subnet.AvailabilityZone
            VpcId            = $subnet.VpcId
            Tags             = $subnet.Tags
        }
        $Object | Add-Member -MemberType NoteProperty -Name "Properties" -Value $Properties

        # ADD VPC OBJECT TO MASTER OBJECT
        $MasterObject | Add-Member -MemberType NoteProperty -Name $Name -Value $Object
    }
    # RETURN MASTER OBJECT
    $MasterObject
}
