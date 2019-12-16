#Requires -Modules AWS.Tools.EC2

function Get-EC2 {
    <# =========================================================================
    .SYNOPSIS
        Get all EC2 instances for given list of accounts
    .DESCRIPTION
        This function returns a list of the EC2 instances in production or in
        all available AWS credential profiles.
    .PARAMETER ProfileName
        Name property of an AWS credential profile
    .PARAMETER Region
        AWS region
    .PARAMETER All
        Use all locally stored AWS credential profiles
    .PARAMETER AWSPowerShell
        Return objects of type Amazon.EC2.Model.Reservation instead of custom
        objects
    .INPUTS
        System.String.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> $All = Get-EC2 -Region us-west-2 -All
        Return all EC2 instances in all AWS accounts represented by the locally
        stored AWS credential profiles in the us-west-2 region.
    ========================================================================= #>
    [CmdletBinding()]
    [OutputType([System.Object[]])]

    Param(
        [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'AWS Profile containing access key and secret')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string[]] $ProfileName,

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
