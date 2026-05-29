function Get-IAMReport {
    <#
    .SYNOPSIS
        Generate and parse AWS IAM report
    .DESCRIPTION
        This function will use the supplied AWS Credential profile to generate and
        parse the IAM Credential Report. It then returns the account information.
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Credential
        AWS Credential Object
    .PARAMETER Path
        File path to existing AWS Credential Report
    .INPUTS
        System.String.
    .OUTPUTS
        System.Object[].
    .EXAMPLE
        PS C:\> Get-IAMReport -ProfileName MyAccount
        Generate IAM report for MyAccount
    .NOTES
        Status: Stable
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List`1[System.Object]])]
    Param(
        [Parameter(HelpMessage = 'AWS Credential profile')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [System.String] $ProfileName,

        [Parameter(HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(HelpMessage = 'Existing AWS Credential Report')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf -Include "*.csv" })]
        [Alias('Data', 'CredentialReport', 'File', 'FilePath', 'Report', 'ReportPath')]
        [System.String] $Path
    )

    Begin {
        # SET VARS
        $date = Get-Date
        $accounts = [System.Collections.Generic.List[System.Object]]::new()

        if ( $PSBoundParameters.ContainsKey('ProfileName') ) {
            $params = @{ ProfileName = $ProfileName }
            $account = $ProfileName
        }
        if ( $PSBoundParameters.ContainsKey('Credential') ) {
            $params = @{ Credential = $Credential }
            $account = (Get-STSCallerIdentity -Credential $Credential).Account
        }

        # IMPORT AWS IAM REPORT
        if ( $PSBoundParameters.ContainsKey('Path') ) {
            $iamReport = Import-Csv -Path $Path
        }
        else {
            # INITIATE REQUEST FOR IAM REPORT AND CHECK FOR STATUS CHANGE EVERY 10 SECONDS
            do {
                $state = (Request-IAMCredentialReport @params).State.Value
                Start-Sleep -Seconds 10
            } while ( $state -eq 'STARTED' )

            # IF THE REPORT STATUS CHANGES TO 'COMPLETE' SET THE REPORT DETAILS TO A VARIABLE
            if ( $state -eq 'COMPLETE' ) {
                $iamReport = Get-IAMCredentialReport -AsTextArray @params | ConvertFrom-Csv
                Write-Verbose -Message ('Report contains [{0}] records' -f $iamReport.Count)
            }
            else {
                Write-Error -Message 'Failed to retrieve report from AWS. Check report status in AWS console' -ErrorAction Stop
            }
        }
    }

    Process {
        # LOOP THROUGH REPORT
        foreach ( $row in $iamReport ) {

            # PASSWORD LAST CHANGED
            if ( $row.password_last_changed -match '\d{4}' ) {
                $passwordLastChanged = [System.DateTime] $row.password_last_changed
            }
            else {
                $passwordLastChanged = 'N/A'
            }

            # LAST LOGIN
            if ( $row.password_last_used -match '\d{4}' ) {
                $passwordLastUsed = [System.DateTime] $row.password_last_used
                $daysSinceLogin = (New-TimeSpan -Start $passwordLastUsed -End $date).Days
            }
            else {
                $passwordLastUsed = 'N/A'
                $daysSinceLogin = 'N/A'
            }

            # ACCESS KEY LAST USED
            if ( $row.access_key_1_last_used_date -match '\d{4}' ) {
                $keyLastUsed = [System.DateTime] $row.access_key_1_last_used_date
                $daysSinceKeyUsed = (New-TimeSpan -Start $keyLastUsed -End $date).Days
            }
            else {
                $keyLastUsed = 'N/A'
                $daysSinceKeyUsed = 'N/A'
            }

            # GROUP MEMBERSHIP (ROOT ACCOUNT ISN'T ALLOWED IN OTHER AWS FUNCTIONS)
            if ( $row.user -eq '<root_account>' ) {
                $groups = '0'
                $primaryGroup = 'N/A'
            }
            else {
                $groupNames = Get-IAMGroupForUser -UserName $row.user @params |
                    Select-Object -ExpandProperty GroupName
                $groups = ($groupNames | Measure-Object).Count
                $primaryGroup = $groupNames | Select-Object -First 1
                if ( -not $primaryGroup ) { $primaryGroup = 'None' }
            }

            $accounts.Add([PSCustomObject] [ordered] @{
                User                = $row.user
                AccessKeyActive     = $row.access_key_1_active
                MFAEnabled          = $row.mfa_active
                Account             = $account
                PasswordEnabled     = $row.password_enabled
                PasswordLastChanged = $passwordLastChanged
                DaysSinceLogin      = $daysSinceLogin
                PasswordLastUsed    = $passwordLastUsed
                DaysSinceKeyUsed    = $daysSinceKeyUsed
                KeyLastUsed         = $keyLastUsed
                Groups              = $groups
                PrimaryGroup        = $primaryGroup
            })
        }

        # RETURN ACCOUNTS
        $accounts
    }
}
