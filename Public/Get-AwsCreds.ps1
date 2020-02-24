#Requires -Modules AWS.Tools.EC2

function Get-AwsCreds {
    <# =========================================================================
    .SYNOPSIS
        Get IAM credential object
    .DESCRIPTION
        Get IAM Credential from IAM Role
    .PARAMETER ProfileName
        AWS Credential Profile name
    .PARAMETER Region
        AWS Region
    .PARAMETER Account
        Custom object containing AWS Account Name and Id properties
    .PARAMETER RoleName
        Name of AWS IAM Role to utilize and obtain credentials
    .INPUTS
        None.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Get-AwsCreds -ProfileName myProfile -Region us-east-1 -AcountId 012345678901 -RoleName mySuperRole
        Get AWS Credential object(s) for account ID 012345678901 and Role name mySuperRole
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, HelpMessage = 'AWS Profile')]
        [ValidateScript( { (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'AWS Region')]
        [ValidateScript( { (Get-AWSRegion).Region -contains $_ })]
        [String] $Region = 'us-east-1',

        [Parameter(Mandatory, HelpMessage = 'PS Object containing AWS Account Name and ID properties')]
        [ValidateNotNullOrEmpty()]
        [System.Object[]] $Account,

        [Parameter(Mandatory, HelpMessage = 'AWS Role name')]
        [ValidateNotNullOrEmpty()]
        [string] $RoleName
    )

    Begin {
        $keys = @{ ProfileName = $ProfileName; Region = $Region }
        $credential = @{ }
    }

    Process {
        foreach ( $a in $Account ) {
            $stsParams = @{
                RoleArn         = "arn:aws:iam::{0}:role/{1}" -f $a.Id, $RoleName
                RoleSessionName = 'SwitchToChild'
            }

            $credential.Add($a.Name, (New-AWSCredential -Credential (Use-STSRole @keys @stsParams).Credentials))
        }
    }

    End {
        $credential
    }
}
