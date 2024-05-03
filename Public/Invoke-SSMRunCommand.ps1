function Invoke-SSMRunCommand {
    <#
    .SYNOPSIS
        Send SNS run command
    .DESCRIPTION
        Send SNS run command with some pre-established values
    .PARAMETER Command
        Command to execute in PowerShell
    .PARAMETER Comment
        SSM command comment
    .PARAMETER Tag
        Instance name tag
    .PARAMETER TimeoutSeconds
        Timeout in seconds
    .PARAMETER TopicARN
        SNS Topic ARN for notification
    .PARAMETER RoleName
        SNS service role name
    .PARAMETER ProfileName
        AWS Profile
    .PARAMETER Region
        AWS Region
    .INPUTS
        None.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Invoke-SSMRunCommand -Command { Get-Service } -Comment 'Get services' -Tag @{Key='Name';Values='MyComputer'} @commonParams
        Runs the command "Get-Service" on system with name tag MyComputer
    .EXAMPLE
        PS C:\> Invoke-SSMRunCommand -Command { Get-Service } -Comment 'Get services' -Tag @{Key='Env';Values='Production'} @commonParams
        Runs the command "Get-Service" on all systems with the 'Production' tag assigned
    .NOTES
        Name:     Invoke-SSMRunCommand
        Author:   Justin Johns
        Version:  0.1.2 | Last Edit: 2024-05-01
        Comments: <Comment(s)>
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = 'Command to execute in PowerShell')]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.ScriptBlock] $Command,

        [Parameter(Mandatory = $false, HelpMessage = 'SSM command comment')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Comment,

        [Parameter(Mandatory = $true, HelpMessage = 'Instance tag (key and values) to run command on')]
        [ValidateNotNullOrEmpty()]
        #[System.Collections.Hashtable] $Tag,
        [Amazon.SimpleSystemsManagement.Model.Target] $Tag,

        [Parameter(Mandatory = $false, HelpMessage = 'Timeout in seconds')]
        [ValidateRange(3600, 172800)]
        [System.Int32] $TimeoutSeconds = 3600,

        [Parameter(Mandatory = $false, HelpMessage = 'SNS Topic ARN for notification')]
        [ValidatePattern('^arn:aws:sns:us-(?:east|west)-[1-2]:\d{12}:[\w-]+$')]
        [System.String] $TopicARN, # 'arn:aws:sns:{0}:{1}:InfrastructureAlerts' -f $Region, $parentAccountId

        [Parameter(Mandatory = $false, HelpMessage = 'SNS service role ARN')]
        #[ValidatePattern('^arn:aws:iam:\d{12}:role/[\w-]+$')]
        [ValidatePattern('^[\w-]+$')]
        [System.String] $RoleName,

        [Parameter(Mandatory = $true, HelpMessage = 'AWS Profile')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [System.String] $ProfileName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, HelpMessage = 'AWS Region')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [ValidateNotNullOrEmpty()]
        [System.String] $Region
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"

        # VALIDATE NOTIFICATION PARAMETERS
        if ($PSBoundParameters.ContainsKey('TopicARN') -and -Not ($PSBoundParameters.ContainsKey('RoleName'))) {
            # ERROR AND TERMINATE
            Write-Error -Message ('Both TopicARN and RoleName must be provided to enable notifications') -ErrorAction Stop
        }
        if ($PSBoundParameters.ContainsKey('RoleName') -and -Not ($PSBoundParameters.ContainsKey('TopicARN'))) {
            # ERROR AND TERMINATE
            Write-Error -Message ('Both TopicARN and RoleName must be provided to enable notifications') -ErrorAction Stop
        }

        # SET ACCOUNT ID
        $accountId = (Get-STSCallerIdentity -ProfileName $ProfileName -Region $Region).Account

        # SET COMMAND HASH
        $cmdParams = @{
            #TimeoutSeconds = 3600 # 3600 seconds = 1 hour # DELIVERY TIMEOUT
            DocumentName = 'AWS-RunPowerShellScript'
            Target       = @{ Key = ('tag:{0}' -f $Tag.Key); Values = $Tag.Values }
            Comment      = $Comment
            Parameter    = @{
                commands         = $Command.ToString()
                executionTimeout = $TimeoutSeconds.ToString()
            }
            ProfileName  = $ProfileName
            Region       = $Region
        }

        # CHECK FOR NOTIFICATION
        if ($PSBoundParameters.ContainsKey('TopicARN')) {
            # ADD NOTIFICATION CONFIGS
            $cmdParams['ServiceRoleArn'] = 'arn:aws:iam::{0}:role/{1}' -f $accountId, $RoleName
            $cmdParams['NotificationConfig_NotificationArn'] = $TopicARN
            $cmdParams['NotificationConfig_NotificationEvent'] = 'Success', 'Failed' # 'InProgress', 'Success', 'TimedOut', 'Cancelled', 'Failed'
            $cmdParams['NotificationConfig_NotificationType'] = 'Command' # 'Invocation'
        }

        # OUTPUT VERBOSE
        Write-Verbose -Message ('Role ARN [{0}]' -f $cmdParams.ServiceRoleArn)
    }
    Process {
        # EXECUTE SSM RUN COMMAND AND RETURN OBJECT
        Send-SSMCommand @cmdParams
    }
}