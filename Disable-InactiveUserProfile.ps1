function Disable-InactiveUserProfile {
    <# =========================================================================
    .SYNOPSIS
        Disable unused IAM User Profile
    .DESCRIPTION
        Disable any IAM User Profiles that has not been used in 90 or more days
    .PARAMETER ProfileName
        AWS Credential Profile name
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
        General notes
    ========================================================================= #>
    [CmdletBinding(DefaultParameterSetName = 'all')]
    Param(
        [Parameter(Mandatory, HelpMessage='AWS credential profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'Age to disable accounts')]
        [ValidateRange(30,365)]
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
        $Results = @()

        # GET ALL USERS IN AWS ACCOUNT
        if ( $PSCmdlet.ParameterSetName -eq 'all' ) { $User = Get-IAMUserList -ProfileName $ProfileName }

        # SET VARS
        $Date = Get-Date
        $BadDate = Get-Date -Date "0001-01-01 00:00"
    }

    Process {
        foreach ( $U in $User ) {
            # SET COMMON VARS
            $Splat = @{ UserName = $U.UserName ; ProfileName = $ProfileName }

            # THE CMDLET Get-IAMLoginProfile HAS ISSUES AND DOES NOT RESPECT STANDARDS
            # LIKE ERRORACTION. THEREFORE, THE COMMANDS BELOW THAT UTILIZE Get-IAMloginProfile
            # WILL OUTPUT ERROR MESSAGES WHEN UNABLE TO LOCATE A LOGIN PROFILE
            try {
                $HasLoginProfile = Get-IAMLoginProfile @Splat -ErrorAction Stop
                Write-Verbose ('Found login profile for user: [{0}]' -f $U.UserName)
            }
            catch {
                $HasLoginProfile = $null
                Write-Verbose ('No login profile found for user: [{0}]' -f $U.UserName)
            }

            # IF USER HAS A VALID LOGIN PROFILE
            if ( $HasLoginProfile ) {

                # VALIDATE LAST LOGIN DATE
                if ( $U.PasswordLastUsed -eq $BadDate ) {
                    $TimeSinceLastLogin = New-TimeSpan -Start $U.CreateDate -End $Date
                } else {
                    $TimeSinceLastLogin = New-TimeSpan -Start $U.PasswordLastUsed -End $Date
                }

                # IF DAYS SINCE LAST LOGIN GREATER OR EQUAL TO AGE
                if ( $TimeSinceLastLogin.Days -ge $Age ) {
                    # CREATE CUSTOM OBJECT
                    $New = @{
                        Arn               = $U.Arn
                        CreateDate        = $U.CreateDate
                        PasswordLastUsed  = $U.PasswordLastUsed
                        DaysSinceLastUsed = $TimeSinceLastLogin.Days
                        UserName          = $U.UserName
                        UserId            = $U.UserId
                    }

                    # CHECK FOR REPORT ONLY
                    if ( $PSBoundParameters.ContainsKey('ReportOnly') ) {
                        # REPORT USER
                        Write-Verbose ('No login for user [{0}] in {1} or more days' -f $Splat.UserName, $Age)
                        $New.Action = 'Report user'
                    } else {
                        # DISABLE USER
                        try {
                            Remove-IAMLoginProfile @Splat -Force
                            Write-Verbose ('DISABLED USER [{0}] in account [{1}]' -f $Splat.UserName, $ProfileName)
                            $New.Action = 'User profile disabled'
                        }
                        catch {
                            Write-Warning ('User [{0}] was not disabled. Error message: {1}' -f $Splat.UserName, $U.Exception.Message)
                            $New.Action = 'Error: {0}' -f $U.Exception.Message
                        }
                    }

                    # ADD TO THE LIST
                    $Results += [PSCustomObject] $New
                }
            }
        }
    }

    End {
        # WRITE VERBOSE OUTPUT
        if ( $PSBoundParameters.ContainsKey('ReportOnly') ) {
            Write-Verbose ('{0} user profile(s) reported. None disabled.' -f $Results.Count)
        } else {
            Write-Verbose ('{0} user profile(s) disabled.' -f $Results.Count)
        }

        # RETURN REVOKED KEYS
        $Results
    }
}
