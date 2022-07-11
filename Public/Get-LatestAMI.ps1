function Get-LatestAMI {
    <# =========================================================================
    .SYNOPSIS
        Get latest Windows AMI from Amazon AWS
    .DESCRIPTION
        Get latest Windows AMI from Amazon AWS
    .PARAMETER OSVersion
        Windows OS version
    .PARAMETER Region
        AWS region
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Credential
        AWS Credential Object
    .INPUTS
        None.
    .OUTPUTS
        Amazon.EC2.Model.Image.
    .EXAMPLE
        PS C:\> Get-LatestAMI -OSVersion Server2016 -ProfileName myProfile -Region us-west-2
        Returns the latest Windows Server 2016 AMI produced by Amazon AWS
    .NOTES
        General notes
    ========================================================================= #>
    [CmdletBinding(DefaultParameterSetName = '__crd')]
    [OutputType([Amazon.EC2.Model.Image])]
    Param(
        [Parameter(Mandatory, Position = 0, HelpMessage = 'Windows OS version')]
        [ValidateSet('Server2016', 'Server2012R2')]
        [string] $OSVersion,

        [Parameter(Mandatory, Position = 1, HelpMessage = 'AWS Region')]
        [ValidateScript({ $_ -in (Get-AWSRegion).Region })]
        [ValidateNotNullOrEmpty()]
        [string] $Region,

        [Parameter(Mandatory, ParameterSetName = '__pro', HelpMessage = 'AWS Profile object')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName,

        [Parameter(Mandatory, ParameterSetName = '__crd', HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential
    )
    Process {

        $descHash = @{
            #Server2012R2 = 'Microsoft Windows Server 2012 R2 RTM 64-bit Locale English AMI provided by Amazon'
            Server2016 = 'Microsoft Windows Server 2016 with Desktop Experience Locale English AMI provided by Amazon'
            Server2019 = 'Microsoft Windows Server 2019 with Desktop Experience Locale English AMI provided by Amazon'
            Server2022 = 'Microsoft Windows Server 2022 Full Locale English AMI provided by Amazon'
        }
        $imageParams = @{
            Region     = $Region
            Owner      = 'amazon'
            Filter     = @(
                @{ Name = 'platform'; Values = 'windows' }
                @{ Name = 'architecture'; Values = 'x86_64' }
                @{ Name = 'description'; Values = $descHash[$OSVersion] }
            )
        }
        switch ($PSCmdlet.ParameterSetName) {
            '__pro' { $imageParams['ProfileName'] = $ProfileName }
            '__crd' { $imageParams['Credential'] = $Credential }
        }

        $ami = Get-EC2Image @imageParams

        #$ami | Format-Table -Property Name, ImageId, CreationDate, Description

        $ami | Sort-Object CreationDate -Descending | Select-Object -First 1
    }
}