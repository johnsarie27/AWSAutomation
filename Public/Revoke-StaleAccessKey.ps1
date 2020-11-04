function Revoke-StaleAccessKey {
    <# =========================================================================
    .SYNOPSIS
        Revoke IAM User Access Key
    .DESCRIPTION
        Revoke any IAM User Access Key that is older than 90 days.
    .PARAMETER UserName
        User name
    .PARAMETER ProfileName
        AWS Credential Profile name
    .PARAMETER Credential
        AWS Credential object
    .PARAMETER Deactivate
        Deactivate key(s)
    .PARAMETER Remove
        Remove key(s)
    .INPUTS
        System.String.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Revoke-AccessKey -UserName jsmith -ProfileName MyAWSAccount
        Remove all access keys for jsmith that are older than 90 days in MyAWSAccount profile.
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding(DefaultParameterSetName='_deactivate')]
    Param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, HelpMessage='User name')]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [Parameter(ValueFromPipelineByPropertyName, HelpMessage='AWS credential profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(ParameterSetName = '_remove', HelpMessage = 'Delete key')]
        [switch] $Remove,

        [Parameter(ParameterSetName='_deactivate', HelpMessage='Disable key')]
        [switch] $Deactivate
    )

    Begin {
        # CREATE RESULTS ARRAY
        $results = [System.Collections.Generic.List[PSObject]]::new()

        # SET AUTHENTICATION
        if ( $PSBoundParameters.ContainsKey('ProfileName') ) { $awsParams = @{ ProfileName = $ProfileName } }
        if ( $PSBoundParameters.ContainsKey('Credential') ) { $awsParams = @{ Credential = $Credential } }
    }

    Process {
        # VALIDATE USERNAME
        if ( $UserName -notin (Get-IAMUserList @awsParams).UserName ) {
            Write-Error ('User [{0}] not found in profile [{1}].' -f $UserName, $ProfileName); Break
        }

        # GET ACCESS KEYS
        $keys = Get-IAMAccessKey -UserName $UserName @awsParams
        if ( !$keys ) { Write-Verbose ('No keys found for user: {0}' -f $UserName) }

        # LOOP THROUGH KEYS
        foreach ( $k in $keys ) {

            # CREATE TIMESPAN
            $span = New-TimeSpan -Start $k.CreateDate -End (Get-Date)

            # IF KEY OLDER THAN 90 DAYS...
            if ( $span.Days -gt 90 ) {
                # REMOVE KEY
                if ( $PSBoundParameters.ContainsKey('Remove') ) {
                    Remove-IAMAccessKey -UserName $k.UserName -AccessKeyId $k.AccessKeyId @awsParams
                }

                # DEACTIVATE KEY
                if ( $PSBoundParameters.ContainsKey('Deactivate') ) {
                    Update-IAMAccessKey -UserName $k.UserName -AccessKeyId $k.AccessKeyId -Status Inactive @awsParams
                }

                # ADD KEY TO LIST
                $results.Add($k)
            }
        }
    }

    End {
        if ( $PSBoundParameters.ContainsKey('Deactivate') ) { $status = 'deactivated' } else { $status = 'removed' }
        if ( $results.Count -eq 1 ) { $num = 'key' } else { $num = 'keys' }

        Write-Verbose ('{0} {1} {2}.' -f $results.Count, $num, $status)

        # RETURN REVOKED KEYS
        $results | Select-Object -ExcludeProperty Status
    }
}
