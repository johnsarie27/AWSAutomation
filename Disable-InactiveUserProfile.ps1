function Disable-InactiveUserProfile {
    <# =========================================================================
    .SYNOPSIS
        Disable unused IAM User Profile
    .DESCRIPTION
        Disable any IAM User Profiles that has not been used in 90 or more days
    .PARAMETER UserName
        User name
    .PARAMETER ProfileName
        AWS Credential Profile name
    .PARAMETER Age
        Age (in days) past which the keys should be disabled
    .PARAMETER All
        All users within the AWS account
    .INPUTS
        System.String.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Disable-InactiveUserProfile -UserName jsmith -ProfileName MyAWSAccount
        Deactivate profile for jsmith if not used in 90 days for MyAWSAccount profile
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding(DefaultParameterSetName = 'user')]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'User name', ParameterSetName = 'user')]
        [ValidateNotNullOrEmpty()]
        [string[]] $UserName,

        [Parameter(Mandatory, HelpMessage='AWS credential profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'Age to disable accounts')]
        [ValidateRange(30,365)]
        [int] $Age = 90,

        [Parameter(Mandatory, HelpMessage = 'All users in account', ParameterSetName = 'all')]
        [switch] $All
    )

    Begin {
        # CREATE RESULTS ARRAY
        $Results = @()

        # GET ALL USERS IN AWS ACCOUNT
        if ( $PSBoundParameters.ContainsKey('All') ) {
            $UserName = (Get-IAMUserList -ProfileName $ProfileName).UserName
        }
    }

    Process {
        $UserName | ForEach-Object {
            # VALIDATE USER
            try { $User = Get-IAMUser -UserName $_ -ProfileName $ProfileName -ErrorAction Stop }
            catch { Write-Error ('User [{0}] not found in profile [{1}].' -f $_, $ProfileName) }

            # SET COMMON VARS
            $Splat = @{ UserName = $User.UserName ; ProfileName = $ProfileName }
            
            # THE CMDLET Get-IAMLoginProfile HAS ISSUES AND DOES NOT RESPECT STANDARDS
            # LIKE ERRORACTION. THEREFORE, THE COMMANDS BELOW THAT UTILIZE Get-IAMloginProfile
            # WILL OUTPUT ERROR MESSAGES WHEN UNABLE TO LOCATE A LOGIN PROFILE
            try { $HasLoginProfile = Get-IAMLoginProfile @Splat -ErrorAction Stop }
            catch { $HasLoginProfile = $null }

            # IF USER HAS A VALID LOGIN PROFILE
            if ( $HasLoginProfile ) {
                # GET DAYS SINCE LAST LOGIN
                $TimeSinceLastLogin = New-TimeSpan -Start $User.PasswordLastUsed -End (Get-Date)
                
                if ( $TimeSinceLastLogin.Days -ge $Age ) {
                    # CREATE CUSTOM OBJECT
                    $New = @{
                        Arn               = $User.Arn
                        CreateDate        = $User.CreateDate
                        PasswordLastUsed  = $User.PasswordLastUsed
                        DaysSinceLastUsed = $TimeSinceLastLogin.Days
                        UserName          = $User.UserName
                        UserId            = $User.UserId
                    }

                    # DISABLE USER
                    try {
                        Remove-IAMLoginProfile @Splat -Force
                        Write-Verbose 'DISABLED USER [{0}] in account [{1}]' -f $Splat.UserName, $ProfileName
                        $New.Action = 'User profile disabled'
                    }
                    catch {
                        Write-Warning ('User [{0}] was not disabled. Error message: {1}' -f $Splat.UserName, $_.Exception.Message)
                        $New.Action = 'Error: {0}' -f $_.Exception.Message
                    }

                    # ADD TO THE LIST
                    $Results += [PSCustomObject] $New
                }
            }
        }
    }

    End {
        Write-Verbose ('{0} user profile(s) disabled.' -f $Results.Count)

        # RETURN REVOKED KEYS
        $Results
    }
}
