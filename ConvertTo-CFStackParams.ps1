function ConvertTo-CFStackParams {
    <# =========================================================================
    .SYNOPSIS
        Deploy CloudFomration Stack
    .DESCRIPTION
        Deploy CloudFomration Stack
    .PARAMETER Parameters
        Hashtable with CloudFormation Stack Parameters
    .INPUTS
        None.
    .OUTPUTS
        Amazon.CloudFormation.Model.Parameter[].
    .EXAMPLE
        PS C:\> ConvertTo-CFStackParams -Parameters @{ pVpcCIDR = '172.16.0.0/16'; pVpcName = 'myNewVpc' }
        Creates and returns new [Amazon.CloudFormation.Model.Parameter] objects for "pVpcCIDR" and "pVpcName"
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'Hashtable with CloudFormation Stack Parameters')]
        [hashtable] $Parameters
    )

    Process {
        # CREATE NEW PARAMETER OBJECTS FROM PARAMETER NAMES AND VALUES
        $paramList = [System.Collections.Generic.List[Amazon.CloudFormation.Model.Parameter]]::new()
        foreach ( $p in $Parameters.Keys ) {
            $new = New-Object -TypeName Amazon.CloudFormation.Model.Parameter
            $new.ParameterKey = $p ; $new.ParameterValue = $Parameters[$p]
            $paramList.Add($new)
        }

        # RETURN PARAMETER OBJECTS
        $paramList
    }
}
