function Revoke-AccessKey {
    <# =========================================================================
    .SYNOPSIS
        Revoke IAM User Access Key
    .DESCRIPTION
        Revoke any IAM User Access Key that is older than 90 days.
    .PARAMETER UserName
        User name
    .PARAMETER ProfileName
        AWS Credential Profile name
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
        [ValidateScript({ $_ -in (Get-IAMUserList).UserName })]
        [string] $UserName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, HelpMessage='AWS credential profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName,

        [Parameter(ParameterSetName='_remove')]
        [switch] $Remove,

        [Parameter(ParameterSetName='_deactivate')]
        [switch] $Deactivate
    )

    Begin {
        # IMPORT AWS MODULE
        Import-Module -Name AWSPowerShell.NetCore

        # CREATE RESULTS ARRAY
        $Results = [System.Collections.Generic.List[PSObject]]::new()
    }

    Process {
        # GET ACCESS KEYS
        $Keys = Get-IAMAccessKey -UserName $UserName -ProfileName $ProfileName
        if ( !$Keys ) { Write-Verbose ('No keys found for user: {0}' -f $UserName) } 

        # LOOP THROUGH KEYS
        $Keys | ForEach-Object -Process {

            # CREATE TIMESPAN
            $Span = New-TimeSpan -Start $_.CreateDate -End (Get-Date)

            # IF KEY OLDER THAN 90 DAYS...
            if ( $Span.Days -gt 90 ) {
                # REMOVE KEY
                if ( $PSBoundParameters.ContainsKey('Remove') ) {
                    Remove-IAMAccessKey -UserName $_.UserName -AccessKeyId $_.AccessKeyId -ProfileName $ProfileName
                }
                
                # DEACTIVATE KEY
                if ( $PSBoundParameters.ContainsKey('Deactivate') ) {
                    Update-IAMAccessKey -UserName $_.UserName -AccessKeyId $_.AccessKeyId -Status Inactive -ProfileName $ProfileName
                }

                # ADD KEY TO LIST
                $Results.Add($_)
            }
        }
    }

    End {
        if ( $PSBoundParameters.ContainsKey('Deactivate') ) { $Status = 'deactivated' }
        else { $Status = 'removed' }
        Write-Output ('[{0}] key(s) {1}.' -f $Results.Count, $Status)

        # RETURN REVOKED KEYS
        Write-Information ($Results | Select-Object -ExcludeProperty Status)
    }
}
