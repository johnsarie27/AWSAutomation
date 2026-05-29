function New-HealthCheckAlarm {
    <#
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
        PS C:\> New-HealthCheckAlarm -Name api-prod-unhealthy -HealthCheckId $id -AlarmActionArn $arn -Credential $c -Region us-east-1
        Creates a CloudWatch alarm in us-east-1 that fires (via $arn) when the
        Route53 health check $id reports unhealthy for three consecutive periods.
    .NOTES
        Status: Stable
    #>
    [CmdletBinding(DefaultParameterSetName = '_profile', SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType([Amazon.CloudWatch.Model.PutMetricAlarmResponse])]
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

        [Parameter(Mandatory = $true, ParameterSetName = '_profile', HelpMessage = 'AWS credential profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [System.String] $ProfileName,

        [Parameter(Mandatory = $true, ParameterSetName = '_credential', HelpMessage = 'AWS credentials object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(Mandatory = $true, HelpMessage = 'AWS region')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [ValidateNotNullOrEmpty()]
        [System.String] $Region
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"

        # SET CREDENTIALS
        if ($PSCmdlet.ParameterSetName -eq '_profile') {
            $awsCreds = @{ ProfileName = $ProfileName; Region = $Region }
        }
        elseif ($PSCmdlet.ParameterSetName -eq '_credential') {
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

        # SHOULD PROCESS
        if ($PSCmdlet.ShouldProcess($Name, "Create new CloudWatch Alarm")) {

            # CREATE ALARM
            Write-CWMetricAlarm @alarmParams @awsCreds
        }
    }
}