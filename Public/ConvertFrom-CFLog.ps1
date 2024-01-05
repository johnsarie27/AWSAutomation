function ConvertFrom-CFLog {
    <#
    .SYNOPSIS
        Convert from CloudFront distribution log
    .DESCRIPTION
        Convert data from CloudFront distribution log into object(s)
    .PARAMETER Path
        Path to log file
    .INPUTS
        System.String.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> ConvertFrom-CFLog -Path C:\cloudfront.log
        Converts content of log file "cloudfront.log" to objects
    .NOTES
        Name:     ConvertFrom-CFLog
        Author:   Justin Johns
        Version:  0.1.0 | Last Edit: 2023-10-30
        - 0.1.0 - Initial version
        Comments: <Comment(s)>
        General notes
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline, HelpMessage = 'Path to log file')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf <# -Include "*.log" #> })]
        [System.String] $Path
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"
    }
    Process {

        # PROCESS EACH LINE
        foreach ($line in (Get-Content -Path $Path)) {

            # GET HEADERS
            if ($line.StartsWith('#Fields:')) {

                # SET HEADERS
                $headers = $line.Replace('#Fields: ', '').Split(' ')
            }
            # CREATE OBJECTS FROM DATA ROWS
            if ($line -NotMatch '^#') {

                # SPLIT LINE
                $split = $line.Split("`t")

                # CREATE HASHTABLE
                $hash = [Ordered] @{}

                # ADD PROPERTY NAME AND VALUE TO HASHTABLE
                for ($i = 0; $i -LT $headers.Count; $i++) { $hash.Add($headers[$i], $split[$i]) }

                # CAST HASHTABLE AS OBJECT AND OUTPUT
                [PSCustomObject] $hash
            }
        }
    }
}