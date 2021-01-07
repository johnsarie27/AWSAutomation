function Disable-InactiveUserProfile {
    <# =========================================================================
    .SYNOPSIS
        Disable unused IAM User Profile
    .DESCRIPTION
        Disable any IAM User Profiles that has not been used in 90 or more days
    .PARAMETER ProfileName
        AWS Credential Profile name
    .PARAMETER Credential
        AWS Credential Object
    .PARAMETER Age
        Age (in days) past which the keys should be disabled
    .PARAMETER All
        All users within the AWS account
    .PARAMETER User
        AWS User object
    .PARAMETER ReportOnly
        Report non-compliant users only
    .INPUTS
        Amazon.IdentityManagement.Model.User[].
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Disable-InactiveUserProfile -ProfileName MyAWSAccount
        Deactivate all profiles if not used in 90 days for MyAWSAccount
    .NOTES
        The identity running this function requires the following permissions:
        - iam:ListUsers
        - iam:GetLoginProfile
        - iam:DeleteLoginProfile
    ========================================================================= #>
    [CmdletBinding(DefaultParameterSetName = 'all')]
    Param(
        [Parameter(HelpMessage='AWS credential profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(HelpMessage = 'Age to disable accounts')]
        [ValidateRange(30, 365)]
        [int] $Age = 90,

        [Parameter(HelpMessage = 'All users in account', ParameterSetName = 'all')]
        [switch] $All,

        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'User name', ParameterSetName = 'user')]
        [ValidateNotNullOrEmpty()]
        [Amazon.IdentityManagement.Model.User[]] $User,

        [Parameter(HelpMessage = 'Report non-compliant users only')]
        [switch] $ReportOnly
    )

    Begin {
        # CREATE RESULTS ARRAY
        $results = [System.Collections.Generic.List[System.Object]]::new()

        # SET CREDENTIALS
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
            # SET COMMON VARS
            $awsParams['UserName'] = $u.UserName

            # THE CMDLET Get-IAMLoginProfile HAS ISSUES AND DOES NOT RESPECT STANDARDS
            # LIKE ERRORACTION. THEREFORE, THE COMMANDS BELOW THAT UTILIZE Get-IAMloginProfile
            # WILL OUTPUT ERROR MESSAGES WHEN UNABLE TO LOCATE A LOGIN PROFILE
            try {
                $hasLoginProfile = Get-IAMLoginProfile @awsParams -ErrorAction Stop
                Write-Verbose ('Found login profile for user: [{0}]' -f $u.UserName)
            }
            catch {
                $hasLoginProfile = $null
                Write-Verbose ('No login profile found for user: [{0}]' -f $u.UserName)
            }

            # IF USER HAS A VALID LOGIN PROFILE
            if ( $hasLoginProfile ) {

                # VALIDATE LAST LOGIN DATE
                if ( $u.PasswordLastUsed -eq $badDate ) {
                    $timeSinceLastLogin = New-TimeSpan -Start $u.CreateDate -End $date
                }
                else {
                    $timeSinceLastLogin = New-TimeSpan -Start $u.PasswordLastUsed -End $date
                }

                # IF DAYS SINCE LAST LOGIN GREATER OR EQUAL TO AGE
                if ( $timeSinceLastLogin.Days -ge $Age ) {
                    # CREATE CUSTOM OBJECT
                    $new = @{
                        Arn               = $u.Arn
                        CreateDate        = $u.CreateDate
                        PasswordLastUsed  = $u.PasswordLastUsed
                        DaysSinceLastUsed = $timeSinceLastLogin.Days
                        UserName          = $u.UserName
                        UserId            = $u.UserId
                    }

                    # CHECK FOR REPORT ONLY
                    if ( $PSBoundParameters.ContainsKey('ReportOnly') ) {
                        # REPORT USER
                        Write-Verbose ('No login for user [{0}] in {1} or more days' -f $awsParams['UserName'], $Age)
                        $new['Action'] = 'Report user'
                    }
                    else {
                        # DISABLE USER
                        try {
                            Remove-IAMLoginProfile @awsParams -Force
                            Write-Verbose ('DISABLED USER [{0}] in account [{1}]' -f $awsParams['UserName'], $ProfileName)
                            $new['Action'] = 'User profile disabled'
                        }
                        catch {
                            Write-Warning ('User [{0}] was not disabled. Error message: {1}' -f $awsParams['UserName'], $u.Exception.Message)
                            $new['Action'] = 'Error: {0}' -f $u.Exception.Message
                        }
                    }

                    # ADD TO THE LIST
                    $results.Add([PSCustomObject] $new)
                }
            }
        }
    }
    End {
        # WRITE VERBOSE OUTPUT
        if ( $PSBoundParameters.ContainsKey('ReportOnly') ) {
            Write-Verbose ('{0} user profile(s) reported. None disabled.' -f $results.Count)
        }
        else {
            Write-Verbose ('{0} user profile(s) disabled.' -f $results.Count)
        }

        # RETURN REVOKED KEYS
        $results
    }
}
