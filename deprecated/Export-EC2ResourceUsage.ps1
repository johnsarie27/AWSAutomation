function Export-EC2ResourceUsage {
    <#
    .SYNOPSIS
        Export report of EC2 CPU and memory utilization
    .DESCRIPTION
        Generate and export a statistical report in Excel format containing CPU
        and memory usage for the past X days
    .PARAMETER Days
        Number of days to generate statistics
    .PARAMETER OutputDirectory
        Path to existing folder for report
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Credential
        AWS Credential Object
    .PARAMETER Region
        AWS region
    .INPUTS
        System.String.
    .OUTPUTS
        System.String.
    .EXAMPLE
        PS C:\> Export-EC2ResourceUsage -Credential $c -Region us-west-1
        Export a report for the past 7 days to the desktop.
    .NOTES
        General notes
    #>
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = 'Number of days to generate statistics')]
        [ValidateRange(1,90)]
        [int] $Days = 7,

        [Parameter(ValueFromPipeline, HelpMessage = 'Path to existing folder for report')]
        [ValidateScript({ Test-Path -Path $_ -PathType Container })]
        [string] $OutputDirectory = "$HOME\Desktop",

        [Parameter(HelpMessage = 'AWS Profile containing key and secret')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(Mandatory, HelpMessage = 'AWS Region')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [string] $Region
    )

    Begin {
        $awsParams = @{ Region = $Region }
        if ( $PSBoundParameters.ContainsKey('ProfileName') ) { $awsParams['ProfileName'] = $ProfileName }
        if ( $PSBoundParameters.ContainsKey('Credential') ) { $awsParams['Credential'] = $Credential }

        $desiredMetrics = @(
            @{ MetricName = "CPUUtilization"; NameSpace = "AWS/EC2"; Unit = "Percent" },
            @{ MetricName = "MemoryAvailable"; NameSpace = "System/Windows"; Unit = "Megabytes" }
        )

        $statParams = @{
            UtcStartTime      = (Get-Date).AddDays(-$days).ToUniversalTime()
            UtcEndTime        = (Get-Date).ToUniversalTime()
            Period            = 60 * 60 * 24 * $days # seconds x minutes x hours x days
            # [Minimum|Maximum|Average|SampleCount|Sum]
            Statistic         = "Minimum", "Maximum", "Average", "SampleCount"
            ExtendedStatistic = "p95", "p99"
        }

        $ec2 = (Get-EC2Instance @awsParams).Instances

        $excelParams = @{
            AutoSize     = $true
            FreezeTopRow = $true
            MoveToEnd    = $true
            BoldTopRow   = $true
            AutoFilter   = $true
            Style        = (New-ExcelStyle -Bold -Range '1:1' -HorizontalAlignment Center)
            Path         = Join-Path -Path $OutputDirectory -ChildPath ('{0}Day-UsageMetrics.xlsx' -f $Days)
        }
    }

    Process {
        foreach ( $m in $desiredMetrics ) {

            $metrics = [System.Collections.Generic.List[System.Object]]::new()

            foreach ($instance in $ec2) {

                $statParams['Dimension'] = @{ Name = 'InstanceId'; Value = $instance.InstanceId }
                $statParams['MetricName'] = $m.MetricName
                $statParams['NameSpace'] = $m.NameSpace
                $statParams['Unit'] = $m.Unit
                $x = (Get-CWMetricStatistic @statParams @awsParams).Datapoints[0]

                $new = [pscustomobject] @{
                    Minimum     = $x.Minimum
                    Average     = $x.Average
                    p95         = $x.ExtendedStatistics['p95']
                    p99         = $x.ExtendedStatistics['p99']
                    Maximum     = $x.Maximum
                    SampleCount = $x.SampleCount
                    Timestamp   = $x.Timestamp
                    Unit        = $x.Unit
                    InstanceId  = $instance.InstanceId
                    Name        = $instance.Name
                    Environment = $instance.Name.Substring(3, 3)
                    #Software    = $instance.Software
                }
                $metrics.Add($new)
            }

            $metrics | Sort-Object Software | Export-Excel @excelParams -WorksheetName $m.MetricName
        }
    }

    End {
        Write-Output -InputObject $excelParams['Path']
    }
}