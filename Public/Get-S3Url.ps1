function Get-S3Url {
    <#
    .SYNOPSIS
        Get S3 object URL
    .DESCRIPTION
        Get S3 object URL
    .PARAMETER BucketName
        S3 Bucket name
    .PARAMETER Key
        S3 Object key
    .PARAMETER Region
        AWS Region
    .INPUTS
        None.
    .OUTPUTS
        System.String.
    .EXAMPLE
        PS C:\> Get-S3Url -BucketName myBucket -Key Files/Test/readme.txt
        Returns the URL "https://myBucket.s3.us-east-1.amazonaws.com/Files/Test/readme.txt"
    .NOTES
        Name:     Get-S3Url
        Author:   Justin Johns
        Version:  0.1.1 | Last Edit: 2024-01-31
        - 0.1.1 - (2024-01-31) Fixed issue with incorrect path using region
        - 0.1.0 - (2023-11-02) Initial version
        Comments: <Comment(s)>
        General notes
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $BucketName,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidatePattern('^[\w\./-]+$')]
        [System.String] $Key,

        [Parameter(Mandatory = $false, Position = 2)]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [System.String] $Region
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"
    }
    Process {
        # CHECK FOR REGION
        if ($PSBoundParameters.ContainsKey('Region')) {
            # RETURN URL
            'https://{0}.s3.{1}.amazonaws.com/{2}' -f $BucketName, $Region, $Key
        }
        else {
            # RETURN URL WITHOUT REGION
            'https://{0}.s3.amazonaws.com/{2}' -f $BucketName, $Key
        }
    }
}