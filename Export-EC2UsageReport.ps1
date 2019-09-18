#Requires -Module ImportExcel

function Export-EC2UsageReport {
    <# =========================================================================
    .SYNOPSIS
        Generate reports for instances offline and running without reservation
    .DESCRIPTION
        This script iterates through all instances in a give AWS Region and creates
        a list of specific attributes. It then finds the last stop time, user who
        stopped the instance, and calculates the number of days the system has been
        stopped (if possible) and creates a data sheet (CSV). The data sheet is then
        imported into Excel and formatted.  This can be done for a single or
        multiple accounts based on AWS Credentail Profiles.
    .PARAMETER DestinationPath
        Path to existing folder for report
    .PARAMETER ProfileName
        This is the name of the AWS Credential profile containing the Access Key and
        Secret Key.
    .PARAMETER Region
        This is the AWS region containing the desired resources to be processed
    .INPUTS
        None.
    .OUTPUTS
        None.
    .EXAMPLE
        PS C:\> Export-EC2UsageReport -Region us-west-1 -ProfileName MyAccount
        Generate new EC2 report for all instances in MyAccount in the us-west-1
        region
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = 'Path to existing folder for report')]
        [ValidateScript({ Test-Path -Path $_ -PathType Container })]
        [Alias('Path')]
        [string] $DestinationPath,

        [Parameter(Mandatory, HelpMessage = 'AWS Credential Profie with key and secret')]
        [ValidateScript({(Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [Alias('PN')]
        [string[]] $ProfileName,

        [Parameter(HelpMessage = 'AWS Region')]
        [ValidateSet('us-east-1','us-east-2','us-west-1','us-west-2')]
        [string] $Region = 'us-east-1',

        [Parameter(HelpMessage = 'Return path to report file')]
        [switch] $PassThru
    )

    Begin {
        # IMPORT REQUIRED MODULES
        Import-Module -Name ImportExcel

        # SET OUTPUT REPORT PATH
        $reportName = 'EC2UsageReport'
        $date = Get-Date -Format "yyyy-MM"
        if ( $PSBoundParameters.ContainsKey('DestinationPath') ) {
            $ReportPath = Join-Path -Path $DestinationPath -ChildPath ('{0}_{1}.xlsx' -f $date, $reportName)
        }
        else {
            $ReportPath = Join-Path -Path "$HOME\Desktop" -ChildPath ('{0}_{1}.xlsx' -f $date, $reportName)
        }

        # SET VAR FOR INSTANCES
        $instanceList = [System.Collections.Generic.List[System.Object]]::new()
        $90DayList = [System.Collections.Generic.List[System.Object]]::new()
        $60DayList = [System.Collections.Generic.List[System.Object]]::new()

        # CREATE PARAMETERS FOR EXCEL EXPORT
        $excelParams = @{
            Path         = $ReportPath
            AutoSize     = $true
            FreezeTopRow = $true
            MoveToEnd    = $true
            BoldTopRow   = $true
            AutoFilter   = $true
            Style        = (New-ExcelStyle -Bold -Range '1:1' -HorizontalAlignment Center)
        }
    }

    Process {
        # POPULATE ARRAY AND ADD DATA VALUES FOR STOP AND COST INFO
        foreach ( $i in (Get-InstanceList -Region $Region -ProfileName $ProfileName) ) { $instanceList.Add($i) }
        foreach ( $instance in $instanceList ) { $instance.GetStopInfo() }
        Get-CostInfo -Region $Region -Ec2Instance $instanceList | Out-Null

        foreach ( $i in $instanceList ) { if ( $i.State -eq 'stopped' ) { $90DayList.Add($i) } }
        foreach ( $i in $instanceList ) { if ( $i.State -eq 'running' ) { $60DayList.Add($i) } }

        # CREATE ARRAY FOR UNATTACHED VOLUMES
        $AllVolumes = Get-AvailableEBS -ProfileName $ProfileName | Group-Object -Property Account | Select-Object Name, Count

        # IF EXISTS EXPORT 60 DAY LIST
        if ( $60DayList.Count -ge 1 ) {
            $props = @('ProfileName', 'Environment', 'Name', 'Type', 'Reserved', 'LastStart', 'DaysRunning', 'OnDemandPrice', 'ReservedPrice', 'Savings')
            $60DayList | Select-Object -Property $props | Sort-Object LastStart | Export-Excel @excelParams -WorksheetName '60-Day Report'
        }

        # IF EXISTS EXPORT 90 DAY LIST
        if ( $90DayList.Count -gt 0 ) {
            $props = @('ProfileName', 'Environment', 'Id', 'Name', 'LastStart', 'LastStopped', 'DaysStopped', 'Stopper')
            $90DayList | Select-Object -Property $props | Sort-Object DaysStopped | Export-Excel @excelParams -WorksheetName '90-Day Report'
        }

        # EXPORT VOLUMES LIST
        if ( $AllVolumes ) {
            $AllVolumes | Export-Excel @excelParams -WorksheetName 'Unattached EBS'
        }
    }

    End {
        # RETURN REPORT PATH
        if ( $PSBoundParameters.ContainsKey('PassThru') ) {
            Write-Output $ReportPath
        }
    }
}