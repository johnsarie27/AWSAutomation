#Requires -Modules AWS.Tools.EC2

function Get-CostInfo {
    <# =========================================================================
    .SYNOPSIS
        Get cost data for EC2 Instance
    .DESCRIPTION
        Populate price data properties for EC2 Instance
    .PARAMETER Ec2Instance
        EC2Instance object
    .PARAMETER Region
        AWS region
    .PARAMETER PassThru
        Returns EC2 instance with cost info
    .PARAMETER Force
        Overwrite any existing cost info
    .INPUTS
        None.
    .OUTPUTS
        EC2Instance
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = 'EC2Instance object')]
        [Amazon.EC2.Model.Instance[]] $Instance,

        [Parameter(HelpMessage = 'AWS region')]
        [ValidateScript( { (Get-AWSRegion).Region -contains $_ })]
        [string] $Region,

        [Parameter(HelpMessage = 'Return EC2 Instance with cost info')]
        [switch] $PassThru,

        [Parameter(HelpMessage = 'Overwrite existing cost info')]
        [switch] $Force
    )

    Begin {
        # GET AWS PRICE DATA
        $dataFile = Export-AWSPriceData

        $regionTable = @{
            'us-east-1' = 'US East (N. Virginia)'
            'us-east-2' = 'US East (Ohio)'
            'us-west-1' = 'US West (N. California)'
            'us-west-2' = 'US West (Oregon)'
        }

        $priceInfo = Import-Csv -Path $dataFile | Where-Object Location -eq $regionTable[$Region]

        $params = @{ MemberType = 'NoteProperty' }
        if ( $PSBoundParameters.ContainsKey('Force') ) { $params.Add('Force', $true) }
    }

    Process {
        foreach ( $i in $Instance ) {
            foreach ( $price in $priceInfo ) {
                if ( $price.'Instance Type' -eq $i.Type -and $price.TermType -eq 'OnDemand' -and $price.CapacityStatus -eq 'Used' ) {
                    [double] $ODP = [math]::Round($price.PricePerUnit, 3)
                    #$i.OnDemandPrice = [math]::Round( $ODP * 24 * 365 )
                    $price = [math]::Round( $ODP * 24 * 365 )
                    $i | Add-Member @params -Name OnDemandPrice -Value $price
                }

                if ( ( $i.Type -eq $price.'Instance Type' ) -and ( $price.TermType -eq 'Reserved' ) ) {
                    #$i.ReservedPrice = $price.PricePerUnit
                    $i | Add-Member @params -Name ReservedPrice -Value $price.PricePerUnit
                }
            }

            try {
                $savings = ( 1 - ( $i.ReservedPrice / $i.OnDemandPrice ) ).ToString("P")
                $i | Add-Member @params -Name Savings -Value $savings
            }
            catch {
                if ( $i ) { $i | Add-Member @params -Name Savings -Value 0 }
            }

        }

        if ( $PSBoundParameters.ContainsKey('PassThru') ) { $Instance }
    }
}
