function New-HealthCheckAlarm {
    <# =========================================================================
    .SYNOPSIS
        Create new CloudWatch Alarm for Route53 Health Check
    .DESCRIPTION
        Create new CloudWatch Alarm for Route53 Health Check using set values
    .PARAMETER Name
        Alarm Name
    .PARAMETER HealthCheckId
        Health Check ID
    .PARAMETER AlarmActionArn
        AWS ARN of Alarm Action
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Credential
        AWS Credential Object
    .PARAMETER Region
        AWS Region
    .INPUTS
        None.
    .OUTPUTS
        None.
    .EXAMPLE
        PS C:\> New-HealthCheckAlarm
        Explanation of what the example does
    .NOTES
        Name:     New-HealthCheckAlarm
        Author:   Justin Johns
        Version:  0.1.0 | Last Edit: 2022-05-26
        - <VersionNotes> (or remove this line if no version notes)
        Comments: <Comment(s)>
        General notes
    ========================================================================= #>
    [CmdletBinding(DefaultParameterSetName = '__crd')]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = 'Alarm Name')]
        [ValidatePattern('^[\w-]+$')]
        [System.String] $Name,

        [Parameter(Mandatory = $true, HelpMessage = 'Health Check ID')]
        [ValidatePattern('\w{8}-(\w{4}-){3}\w{12}')]
        [System.String] $HealthCheckId,

        [Parameter(Mandatory = $true, HelpMessage = 'AWS ARN of Alarm Action')]
        [ValidateNotNullOrEmpty()]
        [System.String] $AlarmActionArn,

        [Parameter(Mandatory = $true, ParameterSetName = '__pro', HelpMessage = 'AWS Profile object')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [System.String] $ProfileName,

        [Parameter(Mandatory = $true, ParameterSetName = '__crd', HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(Mandatory = $true, HelpMessage = 'AWS Region')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [ValidateNotNullOrEmpty()]
        [System.String] $Region
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"

        # SET CREDENTIALS
        if ($PSCmdlet.ParameterSetName -EQ '__pro') {
            $awsCreds = @{ ProfileName = $ProfileName; Region = $Region }
        }
        elseif ($PSCmdlet.ParameterSetName -EQ '__crd') {
            $awsCreds = @{ Credential = $Credential; Region = $Region }
        }
    }
    Process {

        # SET ALARM PARAMETERS
        $alarmParams = @{
            AlarmName          = $Name
            Dimension          = @(
                @{ Name = 'HealthCheckId'; Value = $HealthCheckId }
            )
            AlarmDescription   = 'Alarm for unhealthy Route53 health check'
            AlarmAction        = $AlarmActionArn
            ComparisonOperator = 'LessThanOrEqualToThreshold'
            EvaluationPeriod   = 3
            DatapointsToAlarm  = 3
            Period             = 300
            MetricName         = 'HealthCheckStatus'
            Namespace          = 'AWS/Route53'
            Statistic          = 'Average'
            Threshold          = 0
            Select             = '*'
        }

        # CREATE ALARM
        Write-CWMetricAlarm @alarmParams @awsCreds
    }
}