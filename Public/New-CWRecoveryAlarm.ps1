function New-CWRecoveryAlarm {
    <#
    .SYNOPSIS
        Create new CloudWatch Alarm to Recover Instance
    .DESCRIPTION
        Create new CloudWatch Alarm to Recover Instance based on standard criteria
    .PARAMETER InstanceId
        EC2 Instance Id
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
        PS C:\> New-CWRecoveryAlarm -InstanceId 'i-00000000' -ProfileName 'MyProfie'
        Adds a CloudWatch Alarm to the instance configured to recover after 2 failed status checks of 5 minutes each
    .NOTES
        General notes
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'EC2 Instance Id')]
        [ValidatePattern('i-[\w\d]{8,17}')]
        [Alias('Id', 'Instance')]
        [System.String[]] $InstanceId,

        [Parameter(HelpMessage = 'AWS Credential Profile name')]
        [ValidateScript( { (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [Alias('Profile', 'Name')]
        [System.String] $ProfileName,

        [Parameter(HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(HelpMessage = 'Name of desired AWS Region.')]
        [ValidateScript( { (Get-AWSRegion).Region -contains $_ })]
        [System.String] $Region
    )

    Begin {
        # SET ALARM PARAMS
        $alarmParams = @{
            Region             = $Region
            AlarmAction        = ('arn:aws:automate:{0}:ec2:recover' -f $Region)
            ComparisonOperator = 'GreaterThanOrEqualToThreshold'
            EvaluationPeriod   = 2
            Period             = 300
            MetricName         = 'StatusCheckFailed_System'
            Namespace          = 'AWS/EC2'
            Statistic          = 'Maximum'
            Threshold          = 1
            PassThru           = $true
        }

        # SET AUTHENTICATION
        if ( $PSBoundParameters.ContainsKey('ProfileName') ) { $alarmParams['ProfileName'] = $ProfileName }
        if ( $PSBoundParameters.ContainsKey('Credential') ) { $alarmParams['Credential'] = $Credential }
    }

    Process {
        # LOOP ALL INSTANCES
        foreach ( $Id in $InstanceId ) {
            # UPDATE INSTANCE ID VALUES
            $alarmParams['AlarmName'] = 'awsec2-{0}-High-Status-Check-Failed-System' -f $Id
            $alarmParams['Dimension'] = @{ Name = 'InstanceId'; Value = $Id }

            # CREATE NEW ALARM
            Write-CWMetricAlarm @alarmParams
        }
    }
}