function Get-S3Report {
    <#
    .SYNOPSIS
        Get report information from S3
    .DESCRIPTION
        Get report information on all S3 buckets in an account and region regarding
        version, MFA deletion, and lifecycle policy rules for aborted incomplete
        multi-part uploads
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Credential
        AWS Credential Object
    .PARAMETER Region
        AWS region
    .INPUTS
        None.
    .OUTPUTS
        None.
    .EXAMPLE
        PS C:\> Get-S3Report -ProfileName myProfile -Region us-west-2
        Return an array of objects containing information on the S3 bucket version and lifecycle policies
    .NOTES
        Name:     Get-S3Report
        Author:   Justin Johns
        Version:  0.1.0 | Last Edit: 2024-01-04
        - 0.1.0 - Initial version
        Comments: <Comment(s)>
        General notes
    #>
    [CmdletBinding(DefaultParameterSetName = '__pro')]
    Param(
        [Parameter(Mandatory, Position = 0, ParameterSetName = '__pro', HelpMessage = 'AWS Credential Profile object')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [System.String] $ProfileName,

        [Parameter(Mandatory, Position = 0, ParameterSetName = '__crd', HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(Position = 1, HelpMessage = 'AWS Region')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [System.String] $Region = 'us-east-1'
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"

        # SET CREDENTIALS
        if ($PSCmdlet.ParameterSetName -EQ '__pro') {
            $awsCreds = @{ ProfileName = $ProfileName; Region = $Region }
        }
        else {
            $awsCreds = @{ Credential = $Credential; Region = $Region }
        }
    }
    Process {
        # LIST ALL BUCKETS
        $bucketList = Get-S3Bucket @awsCreds

        # EVALUATE EACH BUCKET
        foreach ($bucket in $bucketList) {

            # GET BUCKET VERSION INFO
            $versionInfo = Get-S3BucketVersioning @awsCreds -BucketName $bucket.BucketName

            # GET LIFECYCLE RULES
            $lifeCycle = Get-S3LifecycleConfiguration @awsCreds -BucketName $bucket.BucketName

            # SET/RESET VARS
            $abortIncompleteMPU = $false
            $days = $null

            # EVALUATE EACH RULE
            foreach ($rule in $lifeCycle.Rules) {

                # CHECK FOR FILTER
                if ($null -EQ $rule.Filter -or $rule.Filter.LifecycleFilterPredicate.Prefix -EQ '') {

                    # CHECK FOR ABORT INCOMPLETE MPU
                    if ($rule.AbortIncompleteMultipartUpload) {
                        # SET VARS
                        $abortIncompleteMPU = $true
                        $days = $rule.AbortIncompleteMultipartUpload.DaysAfterInitiation
                    }
                }
            }

            # CREATE CUSTOM OBJECT
            [PSCustomObject] @{
                BucketName          = $bucket.BucketName
                CreationDate        = $bucket.CreationDate
                Versioning          = $versionInfo.Status
                MfaDeleteEnabled    = $versionInfo.EnableMfaDelete
                LifeCycleRuleForMPU = $abortIncompleteMPU
                DaysAfterInitiation = $days
            }
        }
    }
}