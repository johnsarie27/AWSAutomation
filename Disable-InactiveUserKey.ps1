function Disable-InactiveUserKey {
    <# =========================================================================
    .SYNOPSIS
        Deactivate unused IAM User Access Key
    .DESCRIPTION
        Deactivate IAM User Access Key that has not been used in 90 or more days
    .PARAMETER ProfileName
        AWS Credential Profile name
    .PARAMETER Age
        Age (in days) past which the keys should be disabled
    .PARAMETER All
        All users within the AWS account
    .PARAMETER Remove
        Remove key(s)
    .PARAMETER User
        AWS User Object
    .INPUTS
        Amazon.IdentityManagement.Model.User[].
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Disable-InactiveUserKey -ProfileName MyAWSAccount
        Deactivate all access keys for all users that have not been used in 90 days
        for MyAWSAccount profile.
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding(DefaultParameterSetName = 'all')]
    Param(
        [Parameter(Mandatory, HelpMessage = 'AWS credential profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'Age to disable keys')]
        [ValidateRange(30,365)]
        [int] $Age = 90,

        [Parameter(HelpMessage = 'All users in account', ParameterSetName = 'all')]
        [switch] $All,

        [Parameter(HelpMessage = 'Delete key')]
        [switch] $Remove,

        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'User name', ParameterSetName = 'user')]
        [ValidateNotNullOrEmpty()]
        [Amazon.IdentityManagement.Model.User[]] $User
    )

    Begin {
        # CREATE RESULTS ARRAY
        $Results = [System.Collections.Generic.List[PSObject]]::new()
        
        # GET ALL USERS IN AWS ACCOUNT
        if ( $PSCmdlet.ParameterSetName -eq 'all' ) { $User = Get-IAMUserList -ProfileName $ProfileName }

        # SET VARS
        $Date = Get-Date
        $BadDate = Get-Date -Date "0001-01-01 00:00"
    }

    Process {
        foreach ( $U in $User ) {
            # GET ACCESS KEYS
            $Keys = Get-IAMAccessKey -UserName $U.UserName -ProfileName $ProfileName

            # CHECK FOR KEYS
            if ( !$Keys ) { Write-Verbose ('No keys found for user: [{0}]' -f $U.UserName) } 
            else {

                # EVALUATE KEYS
                $Keys | ForEach-Object -Process {

                    # CHECK IF ACTIVE
                    if ( $_.Status -eq 'Active' ) {

                        # REPORT ACTIVE KEY FOUND
                        Write-Verbose ('Active key found for user [{0}]' -f $U.UserName)

                        # GET LAST USED TIME
                        $IAMAccessKeyLastUsed = Get-IAMAccessKeyLastUsed -AccessKeyId $_.AccessKeyId -ProfileName $ProfileName

                        # VALIDATE LAST USED DATE
                        if ( $IAMAccessKeyLastUsed.AccessKeyLastUsed.LastUsedDate -eq $BadDate ) {
                            $LastUsed = $_.CreateDate
                        } else {
                            $LastUsed = $IAMAccessKeyLastUsed.AccessKeyLastUsed.LastUsedDate
                        }

                        # CREATE TIMESPAN
                        $Span = New-TimeSpan -Start $LastUsed -End $Date

                        # IF KEY ACTIVE AND NOT USED IN LAST 90 DAYS...
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
