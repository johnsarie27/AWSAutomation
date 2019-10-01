function Get-ScanStatus {
    <# =========================================================================
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
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, HelpMessage = 'Bucket name')]
        [ValidateNotNullOrEmpty()]
        [string] $BucketName,

        [Parameter(HelpMessage = 'Key prefix')]
        [ValidateNotNullOrEmpty()]
        [string] $KeyPrefix,

        [Parameter(Mandatory, HelpMessage = 'AWS Profile')]
        [ValidateScript( { (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName
    )

    Begin {
        Import-Module -Name AWSPowerShell.NetCore

        #$bucket = 's3-virus-scan-test' #'esricloud-software'

        $creds = @{ ProfileName = $ProfileName ; BucketName = $BucketName }
        if ( $PSBoundParameters.ContainsKey('KeyPrefix') ) { $creds.Add('KeyPrefix', $KeyPrefix) }

        $objects = Get-S3Object @creds

        if ( $creds['KeyPrefix'] ) { $creds.Remove('KeyPrefix') }
    }

    Process {

        foreach ( $i in $objects ) {

            if ( (Get-S3ObjectTagSet @creds -Key $i.Key).Value -match 'infected' ) {
                [PSCustomObject] @{ Status = 'INFECTED'; Key = $i.Key }
            }
            else {
                [PSCustomObject] @{ Status = 'CLEAN'; Key = $i.Key }
            }
        }
    }
}
