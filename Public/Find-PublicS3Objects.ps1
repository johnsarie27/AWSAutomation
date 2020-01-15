#Requires -Modules AWS.Tools.S3

function Find-PublicS3Objects {
    <# =========================================================================
    .SYNOPSIS
        Find publicly accessible S3 objects
    .DESCRIPTION
        Search S3 bucket(s) and return a list of publicly accessible objects
    .PARAMETER ProfileName
        AWS Credential Profile name
    .PARAMETER Credential
        AWS Credential Object
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
    [OutputType([System.Object[]])]

    Param(
        [Parameter(Mandatory, HelpMessage = 'AWS Credential Profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [Alias('Profile', 'Name')]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'S3 bucket name')]
        [ValidateScript({ $_ -match '^([a-z0-9]{1})([a-zA-Z0-9]|(.(?!(\.|-)))){4,61}([^-]$)' })]
        [Alias('Bucket')]
        [string] $BucketName
    )

    Begin {
        if ( $PSBoundParameters.ContainsKey('ProfileName') ) { $awsParams = @{ ProfileName = $ProfileName } }
        if ( $PSBoundParameters.ContainsKey('Credential') ) { $awsParams = @{ Credential = $Credential } }

        # VALIDATE BUCKET
        if ($PSBoundParameters.ContainsKey('BucketName') ) {
            if ( (Get-S3Bucket @awsParams).BucketName -contains $BucketName ) {
                $buckets = @(Get-S3Bucket @awsParams -BucketName $BucketName)
            }
            else {
                Throw ('Bucket [{0}] not found' -f $BucketName)
            }
        } else {
            $buckets = @(Get-S3Bucket @awsParams)
        }

        $results = [System.Collections.Generic.List[PSObject]]::new()
    }

    Process {
        # ITERATE THROUGH ALL BUCKETS IN ACCOUNT
        foreach ( $b in $buckets ) {

            # $BName = $bucket.BucketName
            $awsParams['BucketName'] = $b.BucketName

            # ITERATE THROUGH ALL OBJECTS IN BUCKET
            foreach ( $i in Get-S3Object @awsParams ) {

                # GET ACL FOR OBJECTS
                $acl = Get-S3ACL @awsParams -Key $i.Key

                # EVALUATE
                foreach ( $grant in $acl.Grants ) {
                    if ( $grant.Grantee.URI -match 'AllUsers' ) {
                        $new = [PSCustomObject] @{
                            BucketName = $awsParams.BucketName
                            Key        = $i.Key
                            Permission = $grant.Permission
                            URI        = $grant.Grantee.URI
                        }
                        #$results += $new
                        $results.Add($new)
                    }
                }
            }
        }
    }

    End {
        $results
    }
}
