function Export-SECSecret {
    <#
    .SYNOPSIS
        Export secret from Secrets Manager
    .DESCRIPTION
        Export secret from Secrets Manager as a secure string into a text file
    .PARAMETER SecretId
        ID of secret in Secrets Manager
    .PARAMETER DestinationPath
        Path to export file
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Credential
        AWS Credential Object
    .PARAMETER Region
        AWS region
    .INPUTS
        None.
    .OUTPUTS
        System.String.
    .EXAMPLE
        PS C:\> Export-SECSecret -SecretId mySecret -DestinationPath C:\
        Retrieves the value of secret 'mySecret' from AWS Secrets Manager and writes
        it to a file under C:\.
    .NOTES
        Status: Stable
    #>
    [CmdletBinding(DefaultParameterSetName = '__crd')]
    [OutputType([System.String])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingConvertToSecureStringWithPlainText',
        '',
        Justification = 'The plaintext password is read from AWS Secrets Manager and immediately converted to a SecureString so it can be exported via ConvertFrom-SecureString. There is no caller-supplied plaintext to avoid.'
    )]
    Param(
        [Parameter(Mandatory, Position = 0, HelpMessage = 'ID of secret in Secrets Manager')]
        [ValidateNotNullOrEmpty()]
        [System.String] $SecretId,

        [Parameter(Mandatory, Position = 1, HelpMessage = 'Path to export file')]
        [ValidateScript({ Test-Path -Path $_ -PathType Container })]
        [Alias('Path')]
        [System.String] $DestinationPath,

        [Parameter(Mandatory, ParameterSetName = '__crd', HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(Mandatory, ParameterSetName = '__pro', HelpMessage = 'AWS Profile object')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [System.String] $ProfileName,

        [Parameter(Mandatory, HelpMessage = 'AWS region')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [System.String] $Region
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"

        # SET COMMON PARAMETERS FOR AUTHENTICATION
        $awsCreds = @{ Region = $Region }

        # SET AUTHENTICATION TYPE
        switch ($PSCmdlet.ParameterSetName) {
            '__pro' { $awsCreds['ProfileName'] = $ProfileName }
            '__crd' { $awsCreds['Credential'] = $Credential }
        }

        # SET DESTINATION FULL PATH
        $fileName = '{0}.txt' -f $SecretId.Replace('/', '_')
        $exportPath = Join-Path -Path $DestinationPath -ChildPath $fileName

        # CHECK FOR EXISTING FILE
        if (Test-Path -Path $exportPath -PathType Leaf) {
            Write-Error -Message ('File already exists: {0}' -f $exportPath) -ErrorAction Stop
        }
    }
    Process {
        # GET SECRET FROM SECRETS MANAGER
        $secret = (Get-SECSecretValue -SecretId $SecretId @awsCreds).SecretString | ConvertFrom-Json

        # GET PASSWORD AS SECURE STRING
        $psaPw = $secret.password | ConvertTo-SecureString -AsPlainText -Force

        # REMOVE SECRET
        Remove-Variable -Name 'secret' -Force

        # EXPORT PASSWORD TO FILE
        $psaPw | ConvertFrom-SecureString | Set-Content -Path $exportPath

        # RETURN PATH TO USER
        Write-Output -InputObject ('File saved to: {0}' -f $exportPath)
    }
}