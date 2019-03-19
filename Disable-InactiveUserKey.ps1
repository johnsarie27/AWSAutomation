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
    .PARAMETER Age
        Age (in days) past which the keys should be disabled
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
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, HelpMessage='User name')]
        [ValidateNotNullOrEmpty()]
        [string[]] $UserName,

        [Parameter(Mandatory, HelpMessage='AWS credential profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'Age to disable keys')]
        [ValidateRange(30,365)]
        [int] $Age = 90,

        [Parameter(HelpMessage='Delete key')]
        [switch] $Remove
    )

    Begin {
        # CREATE RESULTS ARRAY
        $Results = [System.Collections.Generic.List[PSObject]]::new()
    }

    Process {
        foreach ( $user in $UserName ) {
            # VALIDATE USERNAME
            if ( $user -notin (Get-IAMUserList -ProfileName $ProfileName).UserName ) {	
                Write-Error ('User [{0}] not found in profile [{1}].' -f $user, $ProfileName); Break	
            }

            # GET ACCESS KEYS
            $Keys = Get-IAMAccessKey -UserName $user -ProfileName $ProfileName
            if ( !$Keys ) { Write-Verbose ('No keys found for user: {0}' -f $user) } 

            # LOOP THROUGH KEYS
            $Keys | ForEach-Object -Process {

                # GET LAST USED TIME
                $LastUsed = Get-IAMAccessKeyLastUsed -AccessKeyId $_.AccessKeyId -ProfileName $ProfileName

                # CREATE TIMESPAN
                $Span = New-TimeSpan -Start $LastUsed.AccessKeyLastUsed.LastUsedDate -End (Get-Date)

                # IF KEY NOT USED IN LAST 90 DAYS...
                if ( $Span.Days -ge $Age ) {
                    # SET ACTION PARAMS
                    $Splat = @{ UserName = $_.UserName; AccessKeyId = $_.AccessKeyId; ProfileName = $ProfileName }
                    
                    # CREATE NEW CUSTOM OBJECT
                    $New = @{
                        UserName     = $_.UserName
                        AccessKeyId  = $_.AccessKeyId
                        CreateDate   = $_.CreateDate
                        LastUsedDate = $LastUsed.LastUsedDate
                        Region       = $LastUsed.Region
                        ServiceName  = $LastUsed.ServiceName
                        Action       = 'none'
                    }

                    # REMOVE KEY IF SPECIFIED. DEACTIVE AS DEFAULT
                    if ( $PSBoundParameters.ContainsKey('Remove') ) {
                        try { Remove-IAMAccessKey @Splat ; $New.Action = 'Key deleted' }
                        catch { $New.Action = $_.Exception.Message }
                    } else  {
                        try { Update-IAMAccessKey @Splat -Status Inactive ; $New.Action = 'Key deactivated' }
                        catch { $New.Action = $_.Exception.Message }
                    }

                    # ADD OBJECT TO LIST
                    $Results.Add([PSCustomObject]$New)
                }
            }
        }
    }

    End {
        if ( $PSBoundParameters.ContainsKey('Remove') ) { $Status = 'removed' }
        else { $Status = 'deactivated' }
        if ( $Results.Count -eq 1 ) { $Num = 'key' } else { $Num = 'keys' }
        Write-Verbose ('{0} {1} {2}.' -f $Results.Count, $Num, $Status)

        # RETURN REVOKED KEYS
        $Results #| Select-Object -ExcludeProperty Status
    }
}
