#Requires -Modules AWS.Tools.IdentityManagement

function Get-AccountFromRole {
    <# =========================================================================
    .SYNOPSIS
        Get AWS Account ID
    .DESCRIPTION
        Get AWS Account ID(s) from a given IAM Policy
    .PARAMETER PolicyArn
        AWS Policy ARN
    .PARAMETER ProfileName
        AWS Profile containing access keys
    .INPUTS
        System.String
    .OUTPUTS
        System.String[]
    .EXAMPLE
        PS C:\> Get-AccountFromRole -PolicyArn $policyArn -ProfileName myProfile
        Extracts the AWS account ID's from the policy
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'AWS Policy ARN')]
        [ValidateScript({ $_ -match 'arn:aws:iam::\d{12}:.+' })]
        [string] $PolicyArn,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, HelpMessage = 'AWS Profile containing access keys')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName
    )

    Process {
        $cmdParams = @{ ProfileName = $ProfileName; PolicyArn = $PolicyArn }
        $policy = Get-IamPolicy @cmdParams

        $policyVersion = Get-IAMPolicyVersion @cmdParams -VersionId $policy.DefaultVersionId
        Write-Verbose -Message $policyVersion.Document

        [System.Reflection.Assembly]::LoadWithPartialName("System.Web.HttpUtility") | Out-Null
        $policyDocument = [System.Web.HttpUtility]::UrlDecode($policyVersion.Document) | ConvertFrom-Json

        $accounts = foreach ( $resource in $policyDocument.Statement.Resource ) {
            $resource -replace '^arn:aws:iam::(\d{12}):.+$', '$1'
        }

        $accounts
    }
}