#Requires -Modules AWS.Tools.S3

function Find-InsecureS3BucketPolicy {
    <# =========================================================================
    .SYNOPSIS
        Find S3 bucket policies with insecure principle
    .DESCRIPTION
        This function scans through bucket policies for given bucket(s) to identify
        policies that contain principles allowing unauthenticated access.
    .PARAMETER ProfileName
        AWS Credential Profile name
    .PARAMETER BucketName
        S3 bucket name
    .INPUTS
        System.String. Find-S3BucketPolicy accepts a string value for BucketName
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Find-InsecureS3BucketPolicy -ProfileName MyProfile
        Search through all buckets in account represented by MyProfile for bucket
        policies that allow non-authenticated principles.
    ========================================================================= #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]

    Param(
        [Parameter(Mandatory, HelpMessage = 'AWS Credential Profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [Alias('Profile', 'Name')]
        [string] $ProfileName,

        [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'S3 bucket name')]
        [ValidateScript({ $_ -match '^([a-z0-9]{1})([a-z0-9]|(.(?!(\.|-)))){4,61}([^-]$)' })]
        [Alias('Bucket')]
        [string] $BucketName
    )

    Begin {
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
        } else {
            $Buckets = @(Get-S3Bucket @Splat)
        }

        $Results = [System.Collections.Generic.List[System.Object]]::new()
    }

    Process {
        foreach ( $b in $Buckets ) {
            $Splat.BucketName = $b.BucketName

            $Policy = Get-S3BucketPolicy @Splat | ConvertFrom-Json

            foreach ( $i in $Policy.Statement ) {
                if ( $i -and ([string] $i.Principal) -notmatch '(ARN|Service)' ) {
                    $i | Add-Member -MemberType NoteProperty -Name BucketName -Value $Splat.BucketName
                    $Results.Add($i)
                }
            }
        }
    }

    End {
        $Results
    }
}
