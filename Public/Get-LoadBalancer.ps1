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
    [CmdletBinding(DefaultParameterSetName = '_pro')]
    [OutputType([Amazon.ElasticLoadBalancingV2.Model.LoadBalancer[]])]
    Param(
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = '_pro', HelpMessage = 'AWS Profile object')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [System.String[]] $ProfileName,

        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline, ParameterSetName = '_crd', HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials[]] $Credential,

        [Parameter(Position = 1, ValueFromPipelineByPropertyName, HelpMessage = 'AWS Region')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [ValidateNotNullOrEmpty()]
        [System.String] $Region
    )
    Process {
        if ($PSCmdlet.ParameterSetName -eq '_pro') {
            foreach ($name in $ProfileName) {
                # GET LOAD BALANCERS
                Get-ELB2LoadBalancer -ProfileName $name -Region $Region
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq '_crd') {
            foreach ($cred in $Credential) {
                # GET LOAD BALANCERS
                Get-ELB2LoadBalancer -Credential $cred -Region $Region
            }
        }
        else {
            # GET LOAD BALANCERS
            Get-ELB2LoadBalancer -Region $Region
        }

        # OUTPUT VERBOSE
        Write-Verbose -Message ('Elastic load balancers found [{0}]' -f $ec2Instances.Count)
    }
}