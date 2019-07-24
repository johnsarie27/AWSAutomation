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
    .INPUTS
        None.
    .OUTPUTS
        EC2Instance[]
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = 'EC2Instance object')]
        [System.Object[]] $Ec2Instance, # [EC2Instance[]]

        [Parameter(HelpMessage = 'AWS region')]
        [ValidateSet('us-east-1','us-east-2','us-west-1','us-west-2')]
        [string] $Region
    )

    # GET AWS PRICE DATA
    $dataFile = Export-AWSPriceData
    
    $priceInfo = Import-Csv -Path $dataFile | Where-Object Location -eq $RegionTable[$Region]
    foreach ( $instance in $Ec2Instance ) {
        foreach ( $price in $priceInfo ) {
            if ( ( $instance.Type -eq $price.'Instance Type' ) -and ( $price.TermType -eq 'OnDemand' ) ) {
                [double]$ODP = [math]::Round($price.PricePerUnit,3)
                $instance.OnDemandPrice = [math]::Round( $ODP * 24 * 365 )
            }
            if ( ( $instance.Type -eq $price.'Instance Type' ) -and ( $price.TermType -eq 'Reserved' ) ) {
                $instance.ReservedPrice = $price.PricePerUnit
            }
        }
        $instance.Savings = ( 1 - ( $instance.ReservedPrice / $instance.OnDemandPrice ) ).ToString("P")
    }

    $Ec2Instance
}
