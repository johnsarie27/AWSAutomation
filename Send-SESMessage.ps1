function Send-SESMessage {
    <# =========================================================================
    .SYNOPSIS
        Send SES message
    .DESCRIPTION
        Send message via AWS SES using role assigned to EC2 instance
    .PARAMETER ConfigPath
        Path to configuration data file
    .PARAMETER Subject
        Subject for email message
    .PARAMETER Body
        Body of email message
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        None.
    .EXAMPLE
        PS C:\> Send-SESMessage -Path C:\config.json -Subjest 'SES Test' -Body 'This is a test'
        Send email with subject "SES Test" and Body "This is a test"
    .NOTES
        This function must be run on an EC2 instance assigned an IAM role with
        policy allowing SES email send.
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, HelpMessage = 'Path to configuration data file')]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf -Include "*.json" })]
        [Alias('ConfigFile', 'DataFile', 'CP', 'Path')]
        [string] $ConfigPath,

        [Parameter(Mandatory, HelpMessage = 'Message subject')]
        [ValidateScript( { $_.Length -le 60 })]
        [string] $Subject,

        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'Message body')]
        [string] $Body
    )

    Begin {
        # GET CONFIG DATA
        $Config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
        
        # GET SERVER ROLE CREDS
        $Uri = 'http://169.254.169.254/latest/meta-data/iam/security-credentials/roleMemberServer'
        $RoleMetadata = Invoke-RestMethod -Uri $Uri
        $SecretKey = ConvertTo-SecureString -AsPlainText -String $RoleMetadata.SecretAccessKey -Force

        # SET EMAIL PARAMETERS
        $EmailParams = @{
            Credential = New-Object System.Management.Automation.PSCredential($RoleMetadata.AccessKeyId, $SecretKey)
            SmtpServer = 'email-smtp.us-east-1.amazonaws.com'
            From       = $Config.Notification.SecOpsEmail
            To         = $Config.Notification.SecOpsEmail
            UseSsl     = $true
            Port       = 587
        }
    }

    Process {
        # ADD SUBJECT AND BODY
        $EmailParams += @{
            Subject = $Subject
            Body    = $Body
        }

        # SEND MESSAGE
        try { Send-MailMessage @EmailParams -ErrorAction Stop }
        catch { Write-Error $_.Exception.Message }
    }
}