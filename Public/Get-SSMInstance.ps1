function Get-SSMInstance {
    <#
    .SYNOPSIS
        Get SSM Fleet
    .DESCRIPTION
        Get SSM Fleet
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Credential
        AWS Credential Object
    .PARAMETER Region
        AWS region
    .INPUTS
        Amazon.Runtime.AWSCredentials.
    .OUTPUTS
        Amazon.SimpleSystemsManagement.Model.InstanceInformation.
    .EXAMPLE
        PS C:\> $All = Get-SSMInstance -Region us-west-2
        Return all SSM fleet instances using the local system's EC2 Instance Profile
        in the us-west-2 region.
    .NOTES
        Status: Stable
    #>
    [CmdletBinding(DefaultParameterSetName = '_profile')]
    [OutputType([Amazon.SimpleSystemsManagement.Model.InstanceInformation[]])]

    Param(
        [Parameter(Mandatory, Position = 0, ParameterSetName = '_profile', HelpMessage = 'AWS credential profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [System.String[]] $ProfileName,

        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ParameterSetName = '_credential', HelpMessage = 'AWS credentials object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials[]] $Credential,

        [Parameter(Position = 1, ValueFromPipelineByPropertyName, HelpMessage = 'AWS region')]
        [ValidateScript({ $_ -in (Get-AWSRegion).Region })]
        [ValidateNotNullOrEmpty()]
        [System.String] $Region
    )

    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"
    }
    Process {
        if ( $PSCmdlet.ParameterSetName -eq '_profile' ) {
            foreach ( $name in $ProfileName ) {
                Get-SSMInstanceInformation -ProfileName $name -Region $Region
            }
        }
        elseif ( $PSCmdlet.ParameterSetName -eq '_credential' ) {
            foreach ( $cred in $Credential ) {
                Get-SSMInstanceInformation -Credential $cred -Region $Region
            }
        }
        else {
            Get-SSMInstanceInformation -Region $Region
        }
    }
}