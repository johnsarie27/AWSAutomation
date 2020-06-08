#Requires -Modules AWS.Tools.EC2

function Get-EC2 {
    <# =========================================================================
    .SYNOPSIS
        Get all EC2 instances
    .DESCRIPTION
        This function returns a list of the EC2 instances for a given AWS Region
        using the provided AWS Credential Profile. If no profile is provided, the
        system "Instance Profile" will be used.
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Credential
        AWS Credential Object
    .PARAMETER Region
        AWS region
    .PARAMETER AWSPowerShell
        Return objects of type Amazon.EC2.Model.Reservation instead of EC2Instance
        type.
    .INPUTS
        System.String.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> $All = Get-EC2 -Region us-west-2
        Return all EC2 instances using the local system's EC2 Instance Profile
        in the us-west-2 region.
    ========================================================================= #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]

    Param(
        [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'AWS Profile containing access key and secret')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string[]] $ProfileName,

        [Parameter(HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials[]] $Credential,

        [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'AWS Region')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [ValidateNotNullOrEmpty()]
        [string] $Region = 'us-east-1',

        [Parameter(HelpMessage = 'Use AWSPowerShell module')]
        [switch] $AWSPowerShell
    )

    Begin {
        # SET ARRAY FOR RESULTS
        $results = @()
    }

    Process {
        if ( $PSBoundParameters.ContainsKey('ProfileName') ) {
            foreach ( $name in $ProfileName ) {
                $ec2Instances = (Get-EC2Instance -ProfileName $name -Region $Region).Instances
                Write-Verbose -Message ('[{0}] instances found' -f $ec2Instances.Count)

                if ( $PSBoundParameters.ContainsKey('AWSPowerShell') ) { $results += $ec2Instances }
                else { $results += New-Instance -Instance $ec2Instances }
            }
        }
        elseif ( $PSBoundParameters.ContainsKey('Credential') ) {
            foreach ( $cred in $Credential ) {
                $ec2Instances = (Get-EC2Instance -Credential $cred -Region $Region).Instances
                Write-Verbose -Message ('[{0}] instances found' -f $ec2Instances.Count)

                if ( $PSBoundParameters.ContainsKey('AWSPowerShell') ) { $results += $ec2Instances }
                else { $results += New-Instance -Instance $ec2Instances }
            }
        }
        else {
            $ec2Instances = (Get-EC2Instance -Region $Region).Instances
            Write-Verbose -Message ('[{0}] instances found' -f $ec2Instances.Count)

            if ( $PSBoundParameters.ContainsKey('AWSPowerShell') ) { $results = $ec2Instances }
            else { $results = New-Instance -Instance $ec2Instances }
        }
    }

    End {
        # RETURN RESULTS
        $results
    }
}
