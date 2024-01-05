function Disable-InactiveUserKey {
    <#
    .SYNOPSIS
        Deactivate unused IAM User Access Key
    .DESCRIPTION
        Deactivate IAM User Access Key that has not been used in 90 or more days
    .PARAMETER ProfileName
        AWS Credential Profile name
    .PARAMETER Credential
        AWS Credential Object
    .PARAMETER Age
        Age (in days) past which the keys should be disabled
    .PARAMETER All
        All users within the AWS account
    .PARAMETER Remove
        Remove key(s)
    .PARAMETER User
        AWS User Object
    .PARAMETER ReportOnly
        Report non-compliant keys only
    .INPUTS
        Amazon.IdentityManagement.Model.User[].
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Disable-InactiveUserKey -ProfileName MyAWSAccount
        Deactivate all access keys for all users that have not been used in 90 days
        for MyAWSAccount profile.
    .NOTES
        The identity running this function requires the following permissions:
        - iam:ListUsers
        - iam:ListAccessKeys
        - iam:GetAccessKeyLastUsed
        - iam:DeleteAccessKey
        - iam:UpdateAccessKey
    #>
    [CmdletBinding(DefaultParameterSetName = 'all')]
    [OutputType([System.Object[]])]
    Param(
        [Parameter(HelpMessage = 'AWS credential profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(HelpMessage = 'Age to disable keys')]
        [ValidateRange(30,365)]
        [int] $Age = 90,

        [Parameter(HelpMessage = 'All users in account', ParameterSetName = 'all')]
        [switch] $All,

        [Parameter(HelpMessage = 'Delete key')]
        [switch] $Remove,

        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'User name', ParameterSetName = 'user')]
        [ValidateNotNullOrEmpty()]
        [Amazon.IdentityManagement.Model.User[]] $User,

        [Parameter(HelpMessage = 'Report non-compliant keys only')]
        [switch] $ReportOnly
    )

    Begin {
        # CREATE RESULTS ARRAY
        $results = [System.Collections.Generic.List[PSObject]]::new()

        # SET AUTHENTICATION
        if ( $PSBoundParameters.ContainsKey('ProfileName') ) { $awsParams = @{ ProfileName = $ProfileName } }
        if ( $PSBoundParameters.ContainsKey('Credential') ) { $awsParams = @{ Credential = $Credential } }

        # GET ALL USERS IN AWS ACCOUNT
        if ( $PSCmdlet.ParameterSetName -eq 'all' ) { $User = Get-IAMUserList @awsParams }

        # SET VARS
        $date = Get-Date
        $badDate = Get-Date -Date "0001-01-01 00:00"
    }
    Process {
        foreach ( $u in $User ) {
            # GET ACCESS KEYS
            $keys = Get-IAMAccessKey -UserName $u.UserName @awsParams

            # CHECK FOR KEYS
            if ( !$keys ) {
                Write-Verbose ('No keys found for user: [{0}]' -f $u.UserName)
            }
            else {
                # EVALUATE KEYS
                foreach ( $k in $keys ) {
                    # CHECK IF ACTIVE
                    if ( $k.Status -eq 'Active' ) {

                        # REPORT ACTIVE KEY FOUND
                        Write-Verbose ('Active key found for user [{0}]' -f $u.UserName)

                        # GET LAST USED TIME
                        $iamAccessKeyLastUsed = Get-IAMAccessKeyLastUsed -AccessKeyId $k.AccessKeyId @awsParams

                        # VALIDATE LAST USED DATE
                        if ( $iamAccessKeyLastUsed.AccessKeyLastUsed.LastUsedDate -eq $badDate ) {
                            $span = New-TimeSpan -Start $k.CreateDate -End $date
                        }
                        else {
                            $span = New-TimeSpan -Start $iamAccessKeyLastUsed.AccessKeyLastUsed.LastUsedDate -End $date
                        }

                        # IF KEY ACTIVE AND NOT USED IN LAST 90 DAYS...
                        if ( $span.Days -ge $Age ) {
                            # SET ACTION PARAMS
                            $awsParams['UserName'] = $k.UserName
                            $awsParams['AccessKeyId'] = $k.AccessKeyId

                            # CREATE NEW CUSTOM OBJECT
                            $new = @{
                                UserName          = $k.UserName
                                AccessKeyId       = $k.AccessKeyId
                                CreateDate        = $k.CreateDate
                                LastUsedDate      = $iamAccessKeyLastUsed.AccessKeyLastUsed.LastUsedDate
                                DaysSinceLastUsed = $span.Days
                                Region            = $iamAccessKeyLastUsed.AccessKeyLastUsed.Region
                                ServiceName       = $iamAccessKeyLastUsed.AccessKeyLastUsed.ServiceName
                                Action            = 'none'
                            }

                            # CHECK FOR REPORT ONLY
                            if ( $PSBoundParameters.ContainsKey('ReportOnly') ) {
                                # WRITE VERBOSE OUTPUT
                                $new['Action'] = 'Report key'
                            }
                            else {
                                # REMOVE KEY IF SPECIFIED. DEACTIVE AS DEFAULT
                                if ( $PSBoundParameters.ContainsKey('Remove') ) {
                                    try {
                                        Remove-IAMAccessKey @awsParams
                                        $new['Action'] = 'Key deleted'
                                    }
                                    catch {
                                        $new['Action'] = $k.Exception.Message
                                    }
                                }
                                else  {
                                    try {
                                        Update-IAMAccessKey @awsParams -Status Inactive
                                        $new['Action'] = 'Key deactivated'
                                    }
                                    catch {
                                        $new['Action'] = $k.Exception.Message
                                    }
                                }
                            }

                            # ADD OBJECT TO LIST
                            $results.Add([PSCustomObject] $new)
                        }
                    }
                }
            }
        }
    }
    End {
        if ( $PSBoundParameters.ContainsKey('Remove') ) { $status = 'removed' }
        elseif ( $PSBoundParameters.ContainsKey('ReportOnly') ) { $status = 'reported' }
        else { $status = 'deactivated' }

        if ( $results.Count -eq 1 ) { $num = 'key' } else { $num = 'keys' }

        Write-Verbose ('{0} {1} {2}.' -f $results.Count, $num, $status)

        # RETURN REVOKED KEYS
        $results #| Select-Object -ExcludeProperty Status
    }
}
