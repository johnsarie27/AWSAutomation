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
        $Date = Get-Date
        $Accounts = [System.Collections.Generic.List[System.Object]]::new()

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
            $IAMReport = Import-Csv -Path $Path
        }
        else {
            # INITIATE REQUEST FOR IAM REPORT AND CHECK FOR STATUS CHANGE EVERY 10 SECONDS
            do {
                $State = (Request-IAMCredentialReport @params).State.Value
                Start-Sleep -Seconds 10
            } while ( $State -eq 'STARTED' )

            # IF THE REPORT STATUS CHANGES TO 'COMPLETE' SET THE REPORT DETAILS TO A VARIABLE
            if ( $State -eq 'COMPLETE' ) {
                $IAMReport = Get-IAMCredentialReport -AsTextArray @params | ConvertFrom-Csv
                Write-Verbose -Message ('Report contains [{0}] records' -f $IAMReport.Count)
            }
            else {
                Throw 'Failed to retrieve report from AWS. Check report status in AWS console'
            }
        }
    }

    Process {
        # LOOP THROUGH REPORT
        foreach ( $row in $IAMReport ) {
            $new = New-Object -TypeName psobject
            $new | Add-Member -MemberType NoteProperty -Name 'User' -Value $row.user
            $new | Add-Member -MemberType NoteProperty -Name 'AccessKeyActive' -Value $row.access_key_1_active
            $new | Add-Member -MemberType NoteProperty -Name 'MFAEnabled' -Value $row.mfa_active
            #$new | Add-Member -MemberType NoteProperty -Name 'ARN' -Value $row.arn.Substring(0, 25) #THIS 13, ($row.arn.length-13)
            $new | Add-Member -MemberType NoteProperty -Name 'Account' -Value $account
            $new | Add-Member -MemberType NoteProperty -Name 'PasswordEnabled' -Value $row.password_enabled

            # CONVERT DATE FOR PASSWORD LAST CHANGED
            if ( $row.password_last_changed -match '\d{4}' ) {
                [System.DateTime] $plc = $row.password_last_changed
                $new | Add-Member -MemberType NoteProperty -Name 'PasswordLastChanged' -Value $plc
            } else {
                $new | Add-Member -MemberType NoteProperty -Name 'PasswordLastChanged' -Value 'N/A'
            }

            # LAST LOGIN GREATER THAN 90 DAYS
            if ( $row.password_last_used -match '\d{4}' ) {
                [System.DateTime] $PLastUsedDate = $row.password_last_used
                $Span = New-TimeSpan -Start $PLastUsedDate -End $Date
                $new | Add-Member -MemberType NoteProperty -Name 'DaysSinceLogin' -Value $Span.Days
                $new | Add-Member -MemberType NoteProperty -Name 'PasswordLastUsed' -Value $PLastUsedDate
            } else {
                $new | Add-Member -MemberType NoteProperty -Name 'DaysSinceLogin' -Value 'N/A'
                $new | Add-Member -MemberType NoteProperty -Name 'PasswordLastUsed' -Value 'N/A'
            }
            if ( $row.access_key_1_last_used_date -match '\d{4}' ) {
                [System.DateTime] $KLastUsedDate = $row.access_key_1_last_used_date
                $Span = New-TimeSpan -Start $KLastUsedDate -End $Date
                $new | Add-Member -MemberType NoteProperty -Name 'DaysSinceKeyUsed' -Value $Span.Days
                $new | Add-Member -MemberType NoteProperty -Name 'KeyLastUsed' -Value $KLastUsedDate
            } else {
                $new | Add-Member -MemberType NoteProperty -Name 'DaysSinceKeyUsed' -Value 'N/A'
                $new | Add-Member -MemberType NoteProperty -Name 'KeyLastUsed' -Value 'N/A'
            }

            # ROOT ACCOUNT ISN'T ALLOWED IN OTHER AWS FUNCTIONS
            if ( $row.user -eq '<root_account>' ) {
                $new | Add-Member -MemberType NoteProperty -Name 'Groups' -Value '0'
                $new | Add-Member -MemberType NoteProperty -Name 'PrimaryGroup' -Value 'N/A'
            }
            else {
                $Groups = Get-IAMGroupForUser -UserName $row.user @params |
                    Select-Object -ExpandProperty GroupName |
                    Measure-Object | Select-Object -ExpandProperty Count
                $PrimaryGroup = Get-IAMGroupForUser -UserName $row.user @params |
                    Select-Object -ExpandProperty GroupName -First 1
                if ( -not $PrimaryGroup ) { $PrimaryGroup = 'None' }
                $new | Add-Member -MemberType NoteProperty -Name 'Groups' -Value $Groups
                $new | Add-Member -MemberType NoteProperty -Name 'PrimaryGroup' -Value $PrimaryGroup
            }

            # ADD TO COLLECTION
            $Accounts.Add($new)
        }

        # RETURN ACCOUNTS
        $Accounts
    }
}
