#Requires -Modules AWS.Tools.SecurityToken

function Get-RoleCredential {
    <# =========================================================================
    .SYNOPSIS
        Get IAM credential object
    .DESCRIPTION
        Get IAM Credential from IAM Role
    .PARAMETER ProfileName
        AWS Credential Profile name
    .PARAMETER Keys
        AWS access key and secret keys in a PSCredential object
    .PARAMETER Region
        AWS Region
    .PARAMETER Account
        Custom object containing AWS Account Name and Id properties
    .PARAMETER RoleName
        Name of AWS IAM Role to utilize and obtain credentials
    .PARAMETER DurationInSeconds
        Duration of temporary credential in seconds
    .INPUTS
        None.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> $acc = [PSCustomObject] @{ Name = 'myAccount'; Id = '012345678901' }
        PS C:\> Get-RoleCredential -ProfileName myProfile -Region us-east-1 -Acount $acc -RoleName mySuperRole
        Get AWS Credential object(s) for account ID 012345678901 and Role name mySuperRole
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding(DefaultParameterSetName = '_profile')]
    [Alias('Get-AwsCreds')]
    Param(
        [Parameter(Mandatory, HelpMessage = 'AWS Profile', ParameterSetName = '_profile')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName,

        [Parameter(Mandatory, HelpMessage = 'Access key and Secret key', ParameterSetName = '_keys')]
        [ValidateNotNullOrEmpty()]
        [pscredential] $Keys,

        [Parameter(Mandatory, HelpMessage = 'AWS Region')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [string] $Region,

        [Parameter(Mandatory, HelpMessage = 'PS Object containing AWS Account Name and ID properties')]
        [ValidateNotNullOrEmpty()]
        [System.Object[]] $Account,

        [Parameter(Mandatory, HelpMessage = 'AWS Role name')]
        [ValidateNotNullOrEmpty()]
        [string] $RoleName,

        [Parameter(HelpMessage = 'Duration of temporary credential in seconds')]
        [ValidateNotNullOrEmpty()]
        [int] $DurationInSeconds = 3600
    )

    Begin {
        $creds = @{ Region = $Region }

        if ( $PSCmdlet.ParameterSetName -eq '_keys' ) {
            $creds.Add('AccessKey', $Keys.UserName)
            $creds.Add('SecretKey', $Keys.GetNetworkCredential().Password )
        }
        else {
            $creds.Add('ProfileName', $ProfileName)
        }

        $credential = @{ }
    }

    Process {
        foreach ( $acc in $Account ) {
            $stsParams = @{
                RoleArn           = "arn:aws:iam::{0}:role/{1}" -f $acc.Id, $RoleName
                RoleSessionName   = 'SwitchToChild'
                DurationInSeconds = $DurationInSeconds # AWS DEFAULT IS 3600 (1 HOUR)
            }

            $credential.Add($acc.Name, (New-AWSCredential -Credential (Use-STSRole @creds @stsParams).Credentials))
        }
    }

    End {
        $credential
    }
}
