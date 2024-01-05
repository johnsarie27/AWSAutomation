function Export-CertificateReport {
    <# =========================================================================
    .SYNOPSIS
        Export report for certificates
    .DESCRIPTION
        Export report for certificates in Amazon Certificate Manager (similar to UI)
    .PARAMETER Path
        Path to export report
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Credential
        AWS Credential Object
    .PARAMETER Region
        AWS region
    .INPUTS
        None.
    .OUTPUTS
        None.
    .EXAMPLE
        PS C:\> Export-CertificateReport -ProfileName myProfile -Region us-east-1 -Path C:\certReport.xlsx
        Generate report of certificates in Amazon Certificate Manager to C:\certReport.xlsx
    .NOTES
        Name:     Export-CertificateReport
        Author:   Justin Johns
        Version:  0.1.0 | Last Edit: 2024-01-05
        - 0.1.0 - Initial version
        Comments: <Comment(s)>
        General notes
    ========================================================================= #>
    [CmdletBinding(DefaultParameterSetName = '__pro')]
    Param(
        [Parameter(Position = 0, HelpMessage = 'Path to export report')]
        [ValidateScript({ Test-Path -Path (Split-Path -Path $_) -PathType Container })]
        [ValidatePattern('^[\w:\\/-]+\.xlsx$')]
        [System.String] $Path = "$HOME\Desktop\CertificateReport_{0}.xlsx" -f (Get-Date -Format FileDateTime),

        [Parameter(Mandatory, Position = 1, ParameterSetName = '__pro', HelpMessage = 'AWS Credential Profile object')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [System.String] $ProfileName,

        [Parameter(Mandatory, Position = 1, ParameterSetName = '__crd', HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(Position = 2, HelpMessage = 'AWS Region')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [System.String] $Region = 'us-east-1'
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"

        # SET CREDENTIALS
        if ($PSCmdlet.ParameterSetName -EQ '__pro') {
            $awsCreds = @{ ProfileName = $ProfileName; Region = $Region }
        }
        else {
            $awsCreds = @{ Credential = $Credential; Region = $Region }
        }

        # EXCEL PARAM SPLATTER TABLE
        $excelParams = @{
            AutoSize   = $true
            TableStyle = 'Medium2'
            Style      = (New-ExcelStyle -Bold -Range '1:1' -HorizontalAlignment Center)
            Path       = $Path
        }
    }
    Process {
        # GET CERTIFICATE LIST
        $certsList = Get-ACMCertificateList @awsCreds

        # CREATE ARRAY WITH CERT DETAILS
        $certs = foreach ($cert in $certsList) { Get-ACMCertificateDetail @awsCreds -CertificateArn $cert.CertificateArn }

        # EXPORT REPORT
        $certs | Select-Object Report | Export-Excel @excelParams
    }
}