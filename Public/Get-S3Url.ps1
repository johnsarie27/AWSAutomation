function Get-S3Url {
    <#
    .SYNOPSIS
        Get S3 object URL
    .DESCRIPTION
        Get S3 object URL
    .PARAMETER BucketName
        S3 Bucket name
    .PARAMETER Region
        AWS Region
    .PARAMETER Key
        S3 Object key
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
        Version:  0.1.0 | Last Edit: 2023-11-02
        - 0.1.0 - Initial version
        Comments: <Comment(s)>
        General notes
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String] $BucketName,

        [Parameter(Position = 1)]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [System.String] $Region = 'us-east-1',

        [Parameter(Mandatory, Position = 2)]
        [ValidatePattern('^[\w\./-]+$')]
        [System.String] $Key
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"
    }
    Process {
        'https://{0}.s3.{1}.amazonaws.com/{2}' -f $BucketName, $Region, $Key
    }
}