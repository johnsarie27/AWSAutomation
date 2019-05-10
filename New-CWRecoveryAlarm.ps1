function New-CWRecoveryAlarm {
    <# =========================================================================
    .SYNOPSIS
        Create new CloudWatch Alarm to Recover Instance
    .DESCRIPTION
        Create new CloudWatch Alarm to Recover Instance based on standard criteria
    .PARAMETER InstanceId
        EC2 Instance Id
    .PARAMETER ProfileName
        Name property of an AWS credential profile
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
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'EC2 Instance Id')]
        [ValidatePattern('i-[\w\d]{8,17}')]
        [Alias('Id', 'Instance')]
        [string[]] $InstanceId,

        [Parameter(Mandatory, HelpMessage = 'AWS Credential Profile name')]
        [ValidateScript( { (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [Alias('Profile', 'Name')]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'Name of desired AWS Region.')]
        [ValidateSet('us-east-1', 'us-east-2', 'us-west-1', 'us-west-2')]
        [String] $Region = 'us-east-1'
    )

    Begin {
        # SET ALARM PARAMS
        $AlarmParams = @{
            ProfileName        = $ProfileName
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
    }

    Process {
        # LOOP ALL INSTANCES
        foreach ( $Id in $InstanceId ) {
            # UPDATE INSTANCE ID VALUES
            $AlarmParams['AlarmName'] = 'awsec2-{0}-High-Status-Check-Failed-System' -f $Id
            $AlarmParams['Dimension'] = @{ Name = 'InstanceId'; Value = $Id }

            # CREATE NEW ALARM
            Write-CWMetricAlarm @AlarmParams
        }
    }
}