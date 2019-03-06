function Get-IAMReport {
    <# =========================================================================
    .SYNOPSIS
        Generate and parse AWS IAM report
    .DESCRIPTION
        This function will use the supplied AWS Credential profile to generate and
        parse the IAM Credential Report. It then returns the account information.
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER FilePath
        File path to existing AWS Credential Report
    .INPUTS
        System.String.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Get-IAMReport -ProfileName MyAccount
        Generate IAM report for MyAccount
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, HelpMessage = 'AWS Credential profile')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'Existing AWS Credential Report')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf -Include "*.csv" })]
        [Alias('Data', 'CredentialReport', 'File', 'FilePath', 'Report', 'ReportPath')]
        [string] $Path
    )

    $Date = Get-Date

    # IMPORT AWS IAM REPORT
    if ( -not $PSBoundParameters.ContainsKey('Path') ) {
        do {
            $State = (Request-IAMCredentialReport -ProfileName $ProfileName |
            Select-Object -ExpandProperty State).Value ; Start-Sleep -Seconds 10
        } while ( $State -eq 'STARTED' )

        if ( $State -eq 'COMPLETE' ) {
            $DataFile = "$env:TEMP\iam_acc_info.csv"
            Get-IAMCredentialReport -AsTextArray -ProfileName $ProfileName |
            Set-Content -Path $DataFile
        }
        else { Write-Warning 'Failed to retrieve report from AWS. Check report status in AWS console'; Break }
    }
    else { $DataFile = $Path }

    $IAMReport = Import-Csv -Path $DataFile

    # CREATE NEW OBJECTS AND ADD TO LIST
    $Accounts = @()

    foreach ( $row in $IAMReport ) {
        $new = New-Object -TypeName psobject
        $new | Add-Member -MemberType NoteProperty -Name 'User' -Value $row.user
        $new | Add-Member -MemberType NoteProperty -Name 'AccessKeyActive' -Value $row.access_key_1_active
        $new | Add-Member -MemberType NoteProperty -Name 'MFAEnabled' -Value $row.mfa_active
        $new | Add-Member -MemberType NoteProperty -Name 'ARN' -Value $row.arn.Substring(0, 25) #THIS 13, ($row.arn.length-13)
        $new | Add-Member -MemberType NoteProperty -Name 'PasswordEnabled' -Value $row.password_enabled
        
        # CONVERT DATE FOR PASSWORD LAST CHANGED
        if ( $row.password_last_changed -match '\d{4}' ) {
            [datetime] $plc = $row.password_last_changed
            $new | Add-Member -MemberType NoteProperty -Name 'PasswordLastChanged' -Value $plc
        } else { $new | Add-Member -MemberType NoteProperty -Name 'PasswordLastChanged' -Value 'N/A' }
        
        # LAST LOGIN GREATER THAN 90 DAYS
        if ( $row.password_last_used -match '\d{4}' ) {
            [datetime] $PLastUsedDate = $row.password_last_used
            $Span = New-TimeSpan -Start $PLastUsedDate -End $Date
            $new | Add-Member -MemberType NoteProperty -Name 'DaysSinceLogin' -Value $Span.Days
            $new | Add-Member -MemberType NoteProperty -Name 'PasswordLastUsed' -Value $PLastUsedDate
        } else { 
            $new | Add-Member -MemberType NoteProperty -Name 'DaysSinceLogin' -Value 'N/A'
            $new | Add-Member -MemberType NoteProperty -Name 'PasswordLastUsed' -Value 'N/A'
        }
        if ( $row.access_key_1_last_used_date -match '\d{4}' ) {
            [datetime] $KLastUsedDate = $row.access_key_1_last_used_date
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
            $Groups = Get-IAMGroupForUser -UserName $row.user -ProfileName $ProfileName |
            Select-Object -ExpandProperty GroupName |
            Measure-Object | Select-Object -ExpandProperty Count
            $PrimaryGroup = Get-IAMGroupForUser -UserName $row.user -ProfileName $ProfileName |
            Select-Object -ExpandProperty GroupName -First 1
            if ( -not $PrimaryGroup ) { $PrimaryGroup = 'None' }
            $new | Add-Member -MemberType NoteProperty -Name 'Groups' -Value $Groups
            $new | Add-Member -MemberType NoteProperty -Name 'PrimaryGroup' -Value $PrimaryGroup
        }
        $Accounts += $new
    }
    $Accounts
    if ( Test-Path $env:TEMP\iam_acc_info.csv ) {
        Remove-Item -Path $env:TEMP\iam_acc_info.csv -Force
    }
}
