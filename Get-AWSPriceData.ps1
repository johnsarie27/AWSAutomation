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
    .PARAMETER Force
        Overwrite existing data file if present
    .INPUTS
        None.
    .OUTPUTS
        None.
    .EXAMPLE
        PS C:\> GetPriceInfo -Region us-west-2
        Get pricing info for EC2 resources in the us-west-2 region
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
        [string] $Format = '.csv',

        [Parameter(HelpMessage = 'Overwrite existing file')]
        [switch] $Force
    )

    Begin {
        $destFolder = Join-Path -Path $env:ProgramData -ChildPath 'AWS'
        $destFile = Join-Path -Path $destFolder -ChildPath ('{0}_PriceData.csv' -f $OfferCode)

        $dataStats = Get-Item -Path $destFile
        if ( $dataStats.LastWriteTime -ge (Get-Date).AddMonths(-6) -and !$PSBoundParameters.ContainsKey('Force') ) {
            Write-Verbose 'Data file less than 6 months old. Use "Force" parameter to overwrite.'
        }
        else {
            if ( $dataStats -and $PSBoundParameters.ContainsKey('Force') ) {
                Write-Warning 'Overwriting existing data file.'
                Remove-Item -Path $destFile -Force
            }
            if ( !$dataStats -and $PSBoundParameters.ContainsKey('Force') ) {
                Throw 'No data file found.'
            }

            # SET VARS
            $url = "https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/{0}/current/index{1}" -f $OfferCode, $Format
            $dataFile = '{0}\{1}_Raw{2}' -f $env:TEMP, $OfferCode, $Format
            
            if ( -not (Test-Path -Path $destFolder -PathType Container) ) {
                New-Item -Path $destFolder -ItemType Directory | Out-Null
            }

            # DOWNLOAD RAW DATA
            (New-Object System.Net.WebClient).DownloadFile($url, $dataFile)

            # IMPORTING THE DATA BEEN A DIFFICULT TASK BECAUSE THE SHEER VOLUME. I'VE TRIED USING JSON WHICH DOESN'T
            # SEEM TO WORK WELL IMPORTING OR WORKING THE OBJECT. THE BEST/FASTEST SOLUTION I'VE COME UP WITH AFTER
            # HOURS OF TESTING IS CUTTING THE TOP 5 ROWS OFF THE ORIGINAL DOWNLOAD, WRITING THAT TO DISK, THEN
            # IMPORTING THAT DATA FROM THE CSV. THIS STILL TAKES AGES BUT IS QUICKER THAN ANYTHING ELSE I'VE TRIED
            $content = Get-Content -Path $dataFile | Select-Object -Skip 5
            Set-Content -Value $content -Path $dataFile -Force
            $data = Import-Csv -Path $dataFile
    
            # CULL DOWN TO RELEVANT DATA FOR ALL U.S. REGIONS
            $results = [System.Collections.Generic.List[System.Object]]::new()
            $regions = @('US East (N. Virginia)', 'US East (Ohio)', 'US West (N. California)', 'US West (Oregon)')
            foreach ( $row in $data ) {
                if (
                    $row.Location -in $regions -and `
                        $row.'Operating System' -eq 'Windows' -and `
                        $row.Tenancy -eq 'Shared' -and `
                        $row.'Pre Installed S/W' -eq 'NA' -and `
                        $row.'License Model' -ne 'Bring your own license' -and `
                    (
                        (
                            $row.OfferingClass -eq 'standard' -and `
                                $row.PurchaseOption -eq 'All Upfront' -and `
                                $row.Unit -eq 'Quantity' -and `
                                $row.LeaseContractLength -eq '1yr'  #*** EDIT/REMOVE THIS VALUE TO GET MORE INFO ***
                        ) -or `
                            $row.TermType -eq 'OnDemand'
                    )
                ) {
                    $results.Add($row)
                }
            }

            # WRITE NEW FILE WITH PRICE DATA
            $results | Sort-Object -Property 'Instance Type' | Export-Csv -Path $destFile -NoTypeInformation
        }
    }

    End {
        # RETURN PATH TO NEW FILE
        $destFile

        # DELETE REMNANT ARTIFACTS
        if ( Test-Path -Path $dataFile ) { Remove-Item -Path $dataFile -Force }
    }
}
