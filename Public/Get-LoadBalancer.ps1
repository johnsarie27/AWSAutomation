function Get-LoadBalancer {
    <#
    .SYNOPSIS
        Get Elastic Load Balancer v2
    .DESCRIPTION
        Get Elastic Load Balancer v2
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Credential
        AWS Credential Object
    .PARAMETER Region
        AWS region
    .INPUTS
        Amazon.Runtime.AWSCredential.
    .OUTPUTS
        Amazon.ElasticLoadBalancingV2.Model.LoadBalancer.
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .NOTES
        General notes
    #>
    [CmdletBinding(DefaultParameterSetName = '__crd')]
    [OutputType([Amazon.ElasticLoadBalancingV2.Model.LoadBalancer[]])]
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
                Get-ELB2LoadBalancer -ProfileName $name -Region $Region
                #Write-Verbose -Message ('[{0}] instances found' -f $ec2Instances.Count)
            }
        }
        elseif ( $PSCmdlet.ParameterSetName -eq '__crd' ) {
            foreach ( $cred in $Credential ) {
                Get-ELB2LoadBalancer -Credential $cred -Region $Region
                #Write-Verbose -Message ('[{0}] instances found' -f $ec2Instances.Count)
            }
        }
        else {
            Get-ELB2LoadBalancer -Region $Region
            #Write-Verbose -Message ('[{0}] instances found' -f $ec2Instances.Count)
        }
    }
}