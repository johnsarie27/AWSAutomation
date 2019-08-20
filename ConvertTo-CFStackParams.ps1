#Requires -Module AWSPowerShell.NetCore

function ConvertTo-CFStackParams {
    <# =========================================================================
    .SYNOPSIS
        Convert hashtable to CloudFormation Parameter object
    .DESCRIPTION
        Convert hashtable to CloudFormation Parameter object
    .PARAMETER Parameter
        Hashtable with CloudFormation Stack Parameter(s)
    .INPUTS
        None.
    .OUTPUTS
        Amazon.CloudFormation.Model.Parameter[].
    .EXAMPLE
        PS C:\> ConvertTo-CFStackParams -Parameter @{ pVpcCIDR = '172.16.0.0/16'; pVpcName = 'myNewVpc' }
        Output new [Amazon.CloudFormation.Model.Parameter] objects for "pVpcCIDR" and "pVpcName"
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'Hashtable with CloudFormation Stack Parameter(s)')]
        [hashtable] $Parameter
    )

    Process {
        # LOOP THROUGH EACH KEY-VALUE PAIR IN THE HASH TABLE
        foreach ( $p in $Parameter.Keys ) {
            # CREATE NEW PARAMETER OBJECT
            $new = New-Object -TypeName Amazon.CloudFormation.Model.Parameter

            # SET THE KEY TO THE HASH KEY AND VALUE TO THE HASH VALUE
            $new.ParameterKey = $p ; $new.ParameterValue = $Parameter[$p]

            # RETURN THE OBJECT
            $new
        }
    }
}
