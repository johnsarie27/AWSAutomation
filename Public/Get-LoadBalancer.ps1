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
        PS C:\> Get-LoadBalancer -ProfileName MyProfile -Region us-east-1
        Returns every Application/Network Load Balancer (ELBv2) in us-east-1 for
        the account represented by AWS profile 'MyProfile'.
    .NOTES
        Status: Stable
    #>
    [CmdletBinding(DefaultParameterSetName = '_profile')]
    [OutputType([Amazon.ElasticLoadBalancingV2.Model.LoadBalancer[]])]
    Param(
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = '_profile', HelpMessage = 'AWS credential profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [System.String[]] $ProfileName,

        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline, ParameterSetName = '_credential', HelpMessage = 'AWS credentials object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials[]] $Credential,

        [Parameter(Position = 1, ValueFromPipelineByPropertyName, HelpMessage = 'AWS region')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [ValidateNotNullOrEmpty()]
        [System.String] $Region
    )
    Begin {
        Write-Verbose -Message "Starting $($MyInvocation.Mycommand)"
    }
    Process {
        if ($PSCmdlet.ParameterSetName -eq '_profile') {
            foreach ($name in $ProfileName) {
                # GET LOAD BALANCERS
                Get-ELB2LoadBalancer -ProfileName $name -Region $Region
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq '_credential') {
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