function Get-AWSPriceData {
    <# =========================================================================
    .SYNOPSIS
        Get price data for EC2 resources
    .DESCRIPTION
        This function retrieves the EC2 price data for AWS us-east-1 region and
        returns a CSV file with the relevant data.
    .PARAMETER OfferCode
        Offer code for price object resources. Only AmazonEC2 supported at this time
    .PARAMETER Format
        Output format of resulting file. Only CSV supported at this time
    .INPUTS
        System.String.
    .OUTPUTS
        CSV file.
    .EXAMPLE
        PS C:\> GetPriceInfo -Region us-west-2
    .NOTES
        https://aws.amazon.com/blogs/aws/new-aws-price-list-api/
        https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/{offer_code}/current/index.{format}
        https://blogs.technet.microsoft.com/heyscriptingguy/2015/01/30/powertip-use-powershell-to-round-to-specific-decimal-place/
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage='AWS offer code')]
        [ValidateSet({'AmazonEC2'})]
        [string] $OfferCode = 'AmazonEC2',

        [Parameter(HelpMessage = 'Output format')]
        [ValidateSet('.csv')]
        [Alias('Output')]
        [string] $Format = '.csv'
    )

    # SET VARS
    $URL = "https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/{0}/current/index{1}" -f $OfferCode, $Format
    $DataFile = '{0}\{1}_Raw{2}' -f $env:TEMP, $OfferCode, $Format

    # DOWNLOAD RAW DATA
    $WC = New-Object System.Net.WebClient
    $WC.DownloadFile($URL, $DataFile)

    # GET DATA AND STRIP OUT HEADER INFO
    $TotalLines = (Get-Content -Path $DataFile | Measure-Object -Line).Lines
    $RawData = Import-Csv $DataFile -Tail ($TotalLines-5)

    # CULL DOWN TO RELEVANT DATA FOR ALL US REGIONS
    $Output = '{0}\AWS\{1}_PriceData{2}' -f $env:ProgramData, $OfferCode, $Format
    $RawData | Where-Object {
        (
            $_.Location -eq 'US East (N. Virginia)' -or `
            $_.Location -eq 'US East (Ohio)' -or `
            $_.Location -eq 'US West (N. California)' -or `
            $_.Location -eq 'US West (Oregon)'
        ) -and `
        $_.'Operating System' -eq 'Windows' -and `
        $_.Tenancy -eq 'Shared' -and `
        $_.'Pre Installed S/W' -eq 'NA' -and `
        $_.'License Model' -ne 'Bring your own license' -and `
        #$_.PriceDescription -notcontains 'BYOL' -and `
        (
            (
                $_.OfferingClass -eq 'standard' -and `
                $_.PurchaseOption -eq 'All Upfront' -and `
                $_.Unit -eq 'Quantity' -and `
                $_.LeaseContractLength -eq '1yr'  #*** EDIT/REMOVE THIS VALUE TO GET MORE INFO ***
            ) -or `
            $_.TermType -eq 'OnDemand'
        )
    } | Sort-Object -Property 'Instance Type' | Export-Csv $Output -NoTypeInformation

    # DELETE REMNANT ARTIFACTS
    Remove-Item -Path $DataFile -Force
}
