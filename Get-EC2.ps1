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
    [CmdletBinding(DefaultParameterSetName = '__profile')]
    [OutputType([System.Object[]])]

    Param(
        [Parameter(
            Mandatory,
            ValueFromPipelineByPropertyName,
            ParameterSetName = '__profile',
            HelpMessage = 'AWS Profile containing access key and secret'
        )]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [ValidateNotNullOrEmpty()]
        [Alias('Profile')]
        [string[]] $ProfileName,

        [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'AWS Region')]
        [ValidateSet({ (Get-AWSRegion).Region -contains $_ })]
        [ValidateNotNullOrEmpty()]
        [string] $Region = 'us-east-1',

        [Parameter(Mandatory, ParameterSetName = '__all', HelpMessage = 'All Profiles')]
        [switch] $All,

        [Parameter(HelpMessage = 'Use AWSPowerShell module')]
        [switch] $AWSPowerShell
    )

    Begin {
        # SET ARRAY FOR RESULTS
        #$Results = @()
        $Results = [System.Collections.Generic.List[System.Object]]::new()

        # GET ALL PROFILES
        if ( $PSBoundParameters.ContainsKey('All') ) {
            $ProfileName = (Get-AWSCredential -ListProfileDetail).ProfileName
        }
    }

    Process {
        # LOOP ALL PROFILENAME
        foreach ( $p in $ProfileName ) {
            # CHECK FOR AWSPOWERSHELL PARAM
            if ( $PSBoundParameters.ContainsKey('AWSPowerShell') ) {
                # ADD TO RESULTS ARRAY
                $Results.Add( (Get-EC2Instance -ProfileName $p -Region $Region).Instances )
            } else {
                # IF NOT AWSPOWERSHELL ADD CUSTOM OBJECTS TO REULTS ARRAY
                $Results.Add( (Get-InstanceList -ProfileName $p -Region $Region) )
            }
        }
    }

    End {
        # RETURN RESULTS
        $Results
    }
}
