function Get-RoleCredential {
    <#
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
    .PARAMETER SerialNumber
        MFA device serial number
    .PARAMETER TokenCode
        Value provided by MFA device
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
        https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_configure-api-require.html
        https://docs.aws.amazon.com/powershell/latest/reference/index.html?page=Use-STSRole.html&tocid=Use-STSRole
    #>
    [CmdletBinding(DefaultParameterSetName = '_profile')]
    [Alias('Get-AwsCreds')]
    Param(
        [Parameter(Mandatory, HelpMessage = 'AWS Profile', ParameterSetName = '_profile')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [System.String] $ProfileName,

        [Parameter(Mandatory, HelpMessage = 'Access key and Secret key', ParameterSetName = '_keys')]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential] $Keys,

        [Parameter(Mandatory, HelpMessage = 'AWS Region')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [System.String] $Region,

        [Parameter(Mandatory, HelpMessage = 'PS Object containing AWS Account Name and ID properties')]
        [ValidateNotNullOrEmpty()]
        [System.Object[]] $Account,

        [Parameter(Mandatory, HelpMessage = 'AWS Role name')]
        [ValidateNotNullOrEmpty()]
        [System.String] $RoleName,

        [Parameter(HelpMessage = 'MFA device serial number')]
        [System.String] $SerialNumber,

        [Parameter(HelpMessage = 'Value provided by MFA device')]
        [System.String] $TokenCode,

        [Parameter(HelpMessage = 'Duration of temporary credential in seconds')]
        [ValidateNotNullOrEmpty()]
        [System.Int32] $DurationInSeconds = 3600
    )

    Begin {
        # SET REGION
        $creds = @{ Region = $Region }

        # ADD KEYS OR PROFILE
        if ( $PSCmdlet.ParameterSetName -eq '_keys' ) {
            $creds.Add('AccessKey', $Keys.UserName)
            $creds.Add('SecretKey', $Keys.GetNetworkCredential().Password )
        }
        else {
            $creds.Add('ProfileName', $ProfileName)
        }

        # SET STS ROLE SWITCH PARAMETERS
        $stsParams = @{
            RoleSessionName   = 'SwitchToChild'
            DurationInSeconds = $DurationInSeconds # AWS DEFAULT IS 3600 (1 HOUR)
        }

        # ADD MFA SERIAL AND CODE IF PROVIDED
        if ($PSBoundParameters.ContainsKey('SerialNumber')) { $stsParams['SerialNumber'] = $SerialNumber }
        if ($PSBoundParameters.ContainsKey('TokenCode')) { $stsParams['TokenCode'] = $TokenCode }

        # CREATE NEW HASHTABLE
        $credential = @{ }
    }
    Process {
        foreach ( $acc in $Account ) {
            # ADD ROLE ARN
            $stsParams['RoleArn'] = 'arn:aws:iam::{0}:role/{1}' -f $acc.Id, $RoleName

            # GENERATE NEW CREDENTIAL OBJECT AND ADD IT TO HASHTABLE
            $credential.Add($acc.Name, (New-AWSCredential -Credential (Use-STSRole @creds @stsParams).Credentials))
        }
    }
    End {
        # RETURN CREDENTIAL HASHTABLE
        $credential
    }
}