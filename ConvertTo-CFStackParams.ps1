#Requires -Module AWSPowerShell.NetCore

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
        #$paramList = [System.Collections.Generic.List[Amazon.CloudFormation.Model.Parameter]]::new()
        
        # LOOP THROUGH EACH KEY-VALUE PAIR IN THE HASH TABLE
        foreach ( $p in $Parameters.Keys ) {
            # CREATE NEW PARAMETER OBJECT
            $new = New-Object -TypeName Amazon.CloudFormation.Model.Parameter

            # SET THE KEY TO THE HASH KEY AND VALUE TO THE HASH VALUE
            $new.ParameterKey = $p ; $new.ParameterValue = $Parameters[$p]
            
            # RETURN THE OBJECT
            $new

            #$paramList.Add($new)
        }

        #$paramList
    }
}
