function Get-CertificateReport {
    <#
    .SYNOPSIS
        Get report data for certificates
    .DESCRIPTION
        Get report data for certificates in Amazon Certificate Manager (similar to UI)
    .PARAMETER ImportedOnly
        Return IMPORTED certificates only
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
        PS C:\> Get-CertificateReport -ProfileName myProfile -Region us-east-1
        Generate report of certificates in Amazon Certificate Manager to C:\certReport.xlsx
    .NOTES
        Status: Stable
    #>
    [CmdletBinding(DefaultParameterSetName = '_profile')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    Param(
        [Parameter(Position = 1, HelpMessage = 'Return IMPORTED certificates only')]
        [System.Management.Automation.SwitchParameter] $ImportedOnly,

        [Parameter(Mandatory, Position = 2, ParameterSetName = '_profile', HelpMessage = 'AWS credential profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [System.String] $ProfileName,

        [Parameter(Mandatory, Position = 2, ParameterSetName = '_credential', HelpMessage = 'AWS credentials object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(Position = 3, HelpMessage = 'AWS region')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [System.String] $Region = 'us-east-1'
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"

        # SET CREDENTIALS
        if ($PSCmdlet.ParameterSetName -eq '_profile') {
            $awsCreds = @{ ProfileName = $ProfileName; Region = $Region }
        }
        else {
            $awsCreds = @{ Credential = $Credential; Region = $Region }
        }
    }
    Process {
        # GET CERTIFICATE LIST
        $certsList = Get-ACMCertificateList @awsCreds

        # VALIDATE REPORT TYPE
        if ($PSBoundParameters.ContainsKey('ImportedOnly')) {
            # RETURN SECURITY REPORT
            foreach ($cert in $certsList) { Get-ACMCertificateDetail @awsCreds -CertificateArn $cert.CertificateArn | Where-Object Type -EQ 'IMPORTED' | Select-Object Info }
        }
        else {
            # RETURN REPORT
            foreach ($cert in $certsList) { Get-ACMCertificateDetail @awsCreds -CertificateArn $cert.CertificateArn | Select-Object Report }
        }
    }
}