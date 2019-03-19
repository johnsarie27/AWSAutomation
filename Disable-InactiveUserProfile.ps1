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
        [ValidateRange(30,180)]
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
            # GET USER
            $User = Get-IAMUser -UserName -ProfileName $ProfileName
            
            # VALIDATE USERNAME
            if ( $user -notin (Get-IAMUserList -ProfileName $ProfileName).UserName ) {	
                Write-Error ('User [{0}] not found in profile [{1}].' -f $user, $ProfileName); Break
            }
            
            # GET DAYS SINCE LAST LOGIN
            $TimeSinceLastLogin = New-TimeSpan -Start $User.PasswordLastUsed -End (Get-Date)

            # (RE)SET VARIABLE TO NULL FOR EACH USER
            $HasLoginProfile = $null
            # THE CMDLET Get-IAMLoginProfile HAS ISSUES AND DOES NOT RESPECT STANDARD
            # CMDLET PARAMETERS LIKE ERRORACTION. THEREFORE, THE COMMANDS BELOW THAT
            # UTILIZE Get-IAMloginProfile WILL OUTPUT ERROR MESSAGES WHEN UNABLE TO
            # LOCATE A LOGIN PROFILE BECAUSE THE PROFILE HAS BEEN DISABLED.
            $HasLoginProfile = Get-IAMLoginProfile -UserName $User.UserName -EA 0

            # ADD USERS TO NOTIFY LIST IF NOT LOGGED IN 80 DAYS (SINGLE NOTIFICATION)
            if ( $TimeSinceLastLogin.Days -ge $Age -AND $HasLoginProfile ) {
                
                try {
                    Remove-IAMLoginProfile -UserName $User.UserName -ProfileName $ProfileName -Force
                    Write-Verbose 'DISABLED USER [{0}] in account [{1}]' -f $User.UserName, $ProfileName
                    $Results += $User
                }
                catch {
                    Write-Warning ('User [{0}] was not disabled. Error message: {1}' -f $User.UserName, $_.Exception.Message)
                }
            }
        }
    }

    End {
        Write-Verbose ('{0} user profile(s) disabled.' -f $Results.Count)

        # RETURN REVOKED KEYS
        $Results #| Select-Object -ExcludeProperty Status
    }
}
