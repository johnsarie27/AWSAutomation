function Disable-InactiveUserKey {
    <# =========================================================================
    .SYNOPSIS
        Deactivate unused IAM User Access Key
    .DESCRIPTION
        Deactivate any IAM User Access Key that has not been used in 90 or more
        days.
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
        PS C:\> Disable-InactiveUserKey -UserName jsmith -ProfileName MyAWSAccount
        Deactivate all access keys for jsmith that have not been used in 90 days
        for MyAWSAccount profile.
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding(DefaultParameterSetName='_deactivate')]
    Param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, HelpMessage='User name')]
        [ValidateNotNullOrEmpty()]
        [string] $UserName,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, HelpMessage='AWS credential profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName,

        [Parameter(ParameterSetName='_remove', HelpMessage='Delete key')]
        [switch] $Remove,

        [Parameter(ParameterSetName='_deactivate', HelpMessage='Disable key')]
        [switch] $Deactivate
    )

    Begin {
        # CREATE RESULTS ARRAY
        $Results = [System.Collections.Generic.List[PSObject]]::new()
    }

    Process {
        # VALIDATE USERNAME
        if ( $UserName -notin (Get-IAMUserList -ProfileName $ProfileName).UserName ) {	
            Write-Error ('User [{0}] not found in profile [{1}].' -f $UserName, $ProfileName); Break	
        }

        # GET ACCESS KEYS
        $Keys = Get-IAMAccessKey -UserName $UserName -ProfileName $ProfileName
        if ( !$Keys ) { Write-Verbose ('No keys found for user: {0}' -f $UserName) } 

        # LOOP THROUGH KEYS
        $Keys | ForEach-Object -Process {

            # GET LAST USED TIME
            $LastUsed = Get-IAMAccessKeyLastUsed -AccessKeyId $key.AccessKeyId -ProfileName $ProfileName

            # CREATE TIMESPAN
            $Span = New-TimeSpan -Start $LastUsed.AccessKeyLastUsed.LastUsedDate -End (Get-Date)

            # IF KEY NOT USED IN LAST 90 DAYS...
            if ( $Span.Days -gt 90 ) {
                # REMOVE KEY
                if ( $PSBoundParameters.ContainsKey('Remove') ) {
                    Remove-IAMAccessKey -UserName $_.UserName -AccessKeyId $_.AccessKeyId -ProfileName $ProfileName
                }
                
                # DEACTIVATE KEY
                if ( $PSBoundParameters.ContainsKey('Deactivate') ) {
                    Update-IAMAccessKey -UserName $_.UserName -AccessKeyId $_.AccessKeyId -Status Inactive -ProfileName $ProfileName
                }

                # CREATE NEW CUSTOM OBJECT
                $New = [PSCustomObject] @{
                    UserName     = $_.UserName
                    AccessKeyId  = $_.AccessKeyId
                    CreateDate   = $_.CreateDate
                    LastUsedDate = $LastUsed.LastUsedDate
                    Region       = $LastUsed.Region
                    ServiceName  = $LastUsed.ServiceName
                }

                # ADD OBJECT TO LIST
                $Results.Add($New)
            }
        }
    }

    End {
        if ( $PSBoundParameters.ContainsKey('Deactivate') ) { $Status = 'deactivated' }
        else { $Status = 'removed' }
        if ( $Results.Count -eq 1 ) { $Num = 'key' } else { $Num = 'keys' }
        Write-Verbose ('{0} {1} {2}.' -f $Results.Count, $Num, $Status)

        # RETURN REVOKED KEYS
        $Results | Select-Object -ExcludeProperty Status
    }
}
