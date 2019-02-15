function Find-PublicS3Objects {
    <# =========================================================================
    .SYNOPSIS
        Find publicly accessible S3 objects
    .DESCRIPTION
        Search S3 bucket(s) and return a list of publicly accessible objects
    .PARAMETER ProfileName
        AWS Credential Profile name
    .PARAMETER BucketName
        S3 bucket name
    .INPUTS
        System.String. Find-S3BucketPolicy accepts a string value for BucketName
    .OUTPUTS
        System.Object. 
    .EXAMPLE
        PS C:\> Find-PublicS3Objects -ProfileName MyAccount
        Search all objects in all S3 buckets for MyAccount and return a list of publicly accessible objects
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, HelpMessage = 'AWS Credential Profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [Alias('Profile', 'Name')]
        [string] $ProfileName,

        [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'S3 bucket name')]
        [ValidateScript({ $_ -match '^([a-z0-9]{1})([a-zA-Z0-9]|(.(?!(\.|-)))){4,61}([^-]$)' })]
        [Alias('Bucket')]
        [string] $BucketName
    )

    $Splat = @{ ProfileName = $ProfileName }
    
    # VALIDATE BUCKET
    if ($PSBoundParameters.ContainsKey('BucketName') ) {
        if ( (Get-S3Bucket @Splat).BucketName -contains $BucketName ) {
            $Buckets = @(Get-S3Bucket @Splat -BucketName $BucketName)   
        }
        else {
            Write-Warning ('Bucket [{0}] not found' -f $BucketName)
            break
        }
    }
    else { $Buckets = @(Get-S3Bucket @Splat) }

    #$Results = @()
    $Results = [System.Collections.Generic.List[PSObject]]::new()

    # ITERATE THROUGH ALL BUCKETS IN ACCOUNT
    $Buckets | ForEach-Object -Process {

        # $BName = $bucket.BucketName
        $Splat.BucketName = $_.BucketName

        # ITERATE THROUGH ALL OBJECTS IN BUCKET
        Get-S3Object @Splat | ForEach-Object -Process {

            # GET ACL FOR OBJECTS
            $ACL = Get-S3ACL @Splat -Key $_.Key

            # EVALUATE
            foreach ( $grant in $ACL.Grants ) {
                if ( $grant.Grantee.URI -match 'AllUsers' ) {
                    $New = [PSCustomObject] @{
                        BucketName = $Splat.BucketName
                        Key        = $_.Key
                        Permission = $grant.Permission
                        URI        = $grant.Grantee.URI
                    }
                    #$Results += $New
                    $Results.Add($New)
                }
            }
        }
    }

    $Results
}
