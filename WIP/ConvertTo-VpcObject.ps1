function ConvertTo-VpcObject {
    <#
    .SYNOPSIS
        Converts VPCs to an object that can be used to populate a
        CloudFormation template.
    .DESCRIPTION
        This function takes an existing set of VPCs contained in an AWS account
        and outputs an object that can esily be converted into JSON for a
        CloudFormation template.
    .EXAMPLE
        PS C:\> $a = ConvertTo-VpcObject -ProfileName $P -Region us-east-1
        PS C:\> $a | ConvertTo-Json -Depth 8
        This will create the JSON that can be edited to fit into a
        CloudFormation template.
    .INPUTS
        System.String
    .OUTPUTS
        System.Object
    .NOTES
        An object containing vpc(s) objects that can easitly be converted into
        JSON for a CloudFormation template.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, HelpMessage = 'AWS Profile containing key and secret')]
        [ValidateScript( {(Get-AWSCredential -ListProfileDetail).ProfileName -contains $_})]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'AWS Region')]
        [ValidateScript( { (Get-AWSRegion).Region -contains $_ })]
        [string] $Region
    )

    $VPCs = Get-EC2Vpc -ProfileName $ProfileName -Region $Region
    $MasterObject = New-Object -TypeName psobject

    foreach ( $vpc in $VPCs ) {

        $Name = $vpc.Tags | Where-Object Key -EQ Name | Select-Object -EXP Value
        if ( !$Name ) { $Name = $vpc.VpcId.Replace("-", "") }
        $Object = [PSCustomObject] @{ Type = "AWS::EC2::VPC" }

        $Properties = [PSCustomObject] @{
            CidrBlock          = $vpc.CidrBlock
            InstanceTenancy    = $vpc.InstanceTenancy.Value
            EnableDnsSupport   = "true"
            EnableDnsHostnames = "false"
            Tags               = $vpc.Tags
        }
        $Object | Add-Member -MemberType NoteProperty -Name "Properties" -Value $Properties

        # ADD VPC OBJECT TO MASTER OBJECT
        $MasterObject | Add-Member -MemberType NoteProperty -Name $Name -Value $Object
    }
    # RETURN MASTER OBJECT
    $MasterObject
}
