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
    .PARAMETER To
        To address for email message
    .INPUTS
        System.String.
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
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf -Include "*.json" })]
        [Alias('ConfigFile', 'DataFile', 'CP', 'Path')]
        [string] $ConfigPath,

        [Parameter(Mandatory, HelpMessage = 'Message subject')]
        [ValidateScript( { $_.Length -le 60 })]
        [string] $Subject,

        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'Message body')]
        [string] $Body,

        [Parameter(HelpMessage = 'Email to address')]
        [ValidatePattern('[\w-\.]+@.+\.com')]
        [string] $To
    )

    Begin {
        # GET CONFIG DATA
        $Config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
        
        # GET SERVER ROLE CREDS
        $RoleMetadata = Invoke-RestMethod -Uri $Config.AWS.EC2.Metadata
        #$SecretKey = ConvertTo-SecureString -AsPlainText -String $RoleMetadata.SecretAccessKey -Force

        # GET TO ADDRESS
        if ( -not $PSBoundParameters.ContainsKey('To') ) { $Destination = $Config.Notification.SecOpsEmail }
        else { $Destination = $To }

        # SET SES PARAMS
        $SESParams = @{
            Source                = $Config.Notification.SecOpsEmail
            Destination_ToAddress = $Destination
            #Subject_Data          = ''
            #Text_Data             = ''
            AccessKey             = $RoleMetadata.AccessKeyId
            SecretKey             = $RoleMetadata.SecretAccessKey
            SessionToken          = $RoleMetadata.Token
            ErrorAction           = 'Stop'
        }

        <# # SET EMAIL PARAMETERS
        $EmailParams = @{
            Credential  = New-Object System.Management.Automation.PSCredential($RoleMetadata.AccessKeyId, $SecretKey)
            SmtpServer  = 'email-smtp.us-east-1.amazonaws.com'
            From        = $Config.Notification.SecOpsEmail
            To          = $Config.Notification.SecOpsEmail
            UseSsl      = $true
            Port        = 587
            ErrorAction = 'Stop'
        } #>
    }

    Process {
        # ADD SUBJECT AND BODY
        $SESParams += @{ Subject_Data = $Subject; Text_Data = $Body }
        #$EmailParams += @{ Subject = $Subject; Body = $Body }

        # SEND MESSAGE
        try {
            Send-SESEmail @SESParams
            #Send-MailMessage @EmailParams
        }
        catch {
            Write-Error $_.Exception.Message
        }
    }
}