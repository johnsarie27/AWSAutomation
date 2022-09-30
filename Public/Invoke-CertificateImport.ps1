function Invoke-CertificateImport {
    <# =========================================================================
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .PARAMETER PfxFile
        Parameter description (if any)
    .PARAMETER Credential
        AWS Credential Object
    .PARAMETER Region
        AWS region
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .EXAMPLE
        PS C:\> Invoke-CertificateImport
        Explanation of what the example does
    .NOTES
        Name:     Invoke-CertificateImport
        Author:   Justin Johns
        Version:  0.1.0 | Last Edit: 2022-09-29
        - 0.1.0 - Initial version
        Comments: <Comment(s)>
        General notes:
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, HelpMessage = 'Path to PFX file')]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf -Filter "*.pfx", "*.p12" })]
        [System.String] $PfxFile,

        [Parameter(Mandatory, HelpMessage = 'Password to PFX file')]
        [ValidateNotNullOrEmpty()]
        [System.Security.SecureString] $Passowrd,

        [Parameter(HelpMessage = 'ACM Certificate ARN')]
        [ValidatePattern('^arn:aws:acm:[a-z0-9-]+:\d{12}:certificate/[a-z0-9]{8}-([a-z0-9]{4}-){3}[a-z0-9]{12}$')]
        [System.String] $CertificateARN,

        [Parameter(Mandatory, HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(Mandatory, HelpMessage = 'AWS Region')]
        [ValidateScript({ $_ -in (Get-AWSRegion).Region })]
        [System.String] $Region
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"

        # CREATE TEMP FOLDER
        $folder = [System.IO.Path]::GetRandomFileName().Remove(8, 4)

        # EXPORT PEM
        $pemParams = @{
            PFX             = $PfxFile
            OutputDirectory = Join-Path -Path (Split-Path -Path $PfxFile) -ChildPath $folder
            Password        = $Passowrd
            ErrorAction     = 'Stop'
        }
        ConvertTo-PEM @pemParams

        # GET PEM CONTENT
        $pemFile = Get-ChildItem -Path $pemParams.OutputDirectory -Filter '*.pem'
        $pem = Get-Content -Path $pemFile

        # SET LINE MARKERS
        $beginKeyLineNum = ($pem | Select-String -Pattern '-----BEGIN PRIVATE KEY-----').LineNumber
        $endKeyLineNum = ($pem | Select-String -Pattern '-----END PRIVATE KEY-----').LineNumber
        $beginCertLineNums = ($pem | Select-String -Pattern '-----BEGIN CERTIFICATE-----').LineNumber
        $endCertLineNums = ($pem | Select-String -Pattern '-----END CERTIFICATE-----').LineNumber

        # SET FILE PATHS
        $keyFile = Join-Path -Path $pemParams.OutputDirectory -ChildPath 'PRIVATE.key'
        $crtFile = Join-Path -Path $pemParams.OutputDirectory -ChildPath 'Certificate.pem'
        $chnFile = Join-Path -Path $pemParams.OutputDirectory -ChildPath 'Chain.pem'

        # CREATE FILES FOR CERT COMPONENTS
        $pem[($beginKeyLineNum - 1)..($endKeyLineNum - 1)] | Set-Content -Path $keyFile
        $pem[($beginCertLineNums[0] - 1)..($endCertLineNums[0] - 1)] | Set-Content -Path $crtFile
        $pem[($beginCertLineNums[1] - 1)..($endCertLineNums[1] - 1)] | Set-Content -Path $chnFile
        if ($beginCertLineNums[2]) {
            $pem[($beginCertLineNums[2] - 1)..($endCertLineNums[2] - 1)] | Add-Content -Path $chnFile
        }

        # SET IMPORAT PARAMS
        $certParams = @{
            PrivateKey       = [System.IO.File]::ReadAllBytes($keyFile)
            Certificate      = [System.IO.File]::ReadAllBytes($crtFile)
            CertificateChain = [System.IO.File]::ReadAllBytes($chnFile)
            Select           = '*'
            Credential       = $Credential
            Region           = $Region
        }

        # ADD CERTIFICATE ARN TO UPDATE EXISTING ITEM
        if ($PSBoundParameters.ContainsKey('CertificateARN')) {
            $certParams['CertificateARN'] = $CertificateARN
        }

        # IMPORT NEW CERTIFICATE
        Import-ACMCertificate @certParams
    }
    End {
        # REMOVE FILES
        Remove-Item -Path $keyFile, $crtFile, $chnFile
    }
}