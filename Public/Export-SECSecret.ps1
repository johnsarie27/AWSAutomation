function Export-SECSecret {
    <# =========================================================================
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
        Explanation of what the example does
    .NOTES
        Name:      Export-SECSecret
        Author:    Justin Johns
        Version:   0.1.0 | Last Edit: 2022-04-05
        - <VersionNotes> (or remove this line if no version notes)
        Comments: <Comment(s)>
        General notes
    ========================================================================= #>
    [CmdletBinding(DefaultParameterSetName = '__crd')]
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
        [string[]] $ProfileName,

        [Parameter(Mandatory, HelpMessage = 'AWS region')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [string] $Region
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