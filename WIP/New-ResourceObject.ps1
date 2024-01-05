function New-ResourceObject {
    <#
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .PARAMETER abc
        Parameter description (if any)
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .NOTES
        General notes
    #>
    [CmdletBinding(DefaultParameterSetName = 'EIP')]
    Param(
        [Parameter(Mandatory, ParameterSetName = 'EIP', HelpMessage = 'Elastic IP')]
        [switch] $EIP,

        [Parameter(Mandatory, ParameterSetName = 'NGW', HelpMessage = 'NAT Gateway')]
        [switch] $NGW,

        [Parameter(Mandatory, ParameterSetName = 'IGW', HelpMessage = 'Internet Gateway')]
        [switch] $IGW,

        [Parameter(Mandatory, ParameterSetName = 'VGA', HelpMessage = 'VPC Gateway Attachment')]
        [switch] $VGA,

        [Parameter(HelpMessage = 'Value for name tag')]
        [ValidateScript( { $_ -match '[A-Z0-9-_]' })]
        [string] $NameTag,

        [Parameter(Mandatory, ParameterSetName = 'NGW', HelpMessage = 'Elast IP name')]
        [ValidateScript( { $_ -match '[A-Z0-9-_]' })]
        [string] $EipName,

        [Parameter(Mandatory, ParameterSetName = 'NGW', HelpMessage = 'Subnet name')]
        [ValidateScript( { $_ -match '[A-Z0-9-_]' })]
        [string] $SubnetName
    )

    $ParamSwitch = @('EIP', 'NGW', 'IGW', 'VGA')
    switch ( $PSBoundParameters.Keys | Where-Object { $_ -in $ParamSwitch } ) {
        'EIP' {
            $ResourceType = 'EIP'
            $Hash = @{ Domain = "vpc" }
        }
        'NGW' {
            $ResourceType = 'NatGateway'
            $Hash = @{
                AllocationId = [PSCustomObject] @{ "Fn::GetAtt" = @($EipName, "AllocationId") }
                SubnetId     = [PSCustomObject] @{ Ref = "$SubnetName" }
            }
        }
        'IGW' { $ResourceType = 'InternetGateway' }
        'VGA' {
            $ResourceType = 'VPCGatewayAttachment'
            $Hash = @{
                VpcId             = [PSCustomObject] @{ Ref = "rVPC" }
                InternetGatewayId = [PSCustomObject] @{ Ref = "rInternetGateway" }
            }
        }
    }

    if ( $Hash -and $NameTag ) {
        $Hash.Tags = [PSCustomObject] @{ Key = "Name" ; Value = $NameTag }
    }
    if ( -not $Hash -and $NameTag ) {
        $Hash = @{ Tags = [PSCustomObject] @{ Key = "Name" ; Value = $NameTag } }
    }

    # ADD DATA VALUES AND OBJECTS
    $Object = [PSCustomObject] @{ Type = "AWS::EC2::$ResourceType" }
    if ( $Hash ) { $Properties = [PSCustomObject] $Hash }
    $Object | Add-Member -MemberType NoteProperty -Name "Properties" -Value $Properties

    # RETURN MASTER OBJECT
    $Object
}