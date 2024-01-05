function Get-Instance {
    <#
    .SYNOPSIS
        Get all EC2 instances
    .DESCRIPTION
        This function returns a list of the EC2 instances for a given AWS Region
        using the provided AWS Credential Profile or Credential object. If no
        profile is provided, the system "Instance Profile" will be used.
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Credential
        AWS Credential Object
    .PARAMETER Region
        AWS region
    .INPUTS
        Amazon.Runtime.AWSCredentials.
    .OUTPUTS
        Amazon.EC2.Model.Instance.
    .EXAMPLE
        PS C:\> $All = Get-Instance -Region us-west-2
        Return all EC2 instances using the local system's EC2 Instance Profile
        in the us-west-2 region.
    #>
    [CmdletBinding(DefaultParameterSetName = '__crd')]
    [OutputType([Amazon.EC2.Model.Instance[]])]

    Param(
        [Parameter(Mandatory, Position = 0, ParameterSetName = '__pro', HelpMessage = 'AWS Profile object')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [System.String[]] $ProfileName,

        [Parameter(Mandatory, Position = 0, ValueFromPipeline, ParameterSetName = '__crd', HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials[]] $Credential,

        [Parameter(Position = 1, ValueFromPipelineByPropertyName, HelpMessage = 'AWS Region')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [ValidateNotNullOrEmpty()]
        [System.String] $Region
    )

    Process {
        if ( $PSCmdlet.ParameterSetName -eq '__pro' ) {
            foreach ( $name in $ProfileName ) {
                (Get-EC2Instance -ProfileName $name -Region $Region).Instances
                #Write-Verbose -Message ('[{0}] instances found' -f $ec2Instances.Count)
            }
        }
        elseif ( $PSCmdlet.ParameterSetName -eq '__crd' ) {
            foreach ( $cred in $Credential ) {
                (Get-EC2Instance -Credential $cred -Region $Region).Instances
                #Write-Verbose -Message ('[{0}] instances found' -f $ec2Instances.Count)
            }
        }
        else {
            (Get-EC2Instance -Region $Region).Instances
            #Write-Verbose -Message ('[{0}] instances found' -f $ec2Instances.Count)
        }
    }
}
