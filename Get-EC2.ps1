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
    Param(
        [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'AWS Profile containing access key and secret')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [ValidateNotNullOrEmpty()]
        [Alias('Profile')]
        [string[]] $ProfileName,

        [Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'AWS Region')]
        [ValidateSet('us-east-1','us-east-2','us-west-1','us-west-2')]
        [ValidateNotNullOrEmpty()]
        [string] $Region = 'us-east-1',

        [Parameter(HelpMessage = 'All Profiles')]
        [switch] $All,

        [Parameter(HelpMessage = 'Use AWSPowerShell module')]
        [switch] $AWSPowerShell
    )

    $Results = @()

    if ( $PSBoundParameters.ContainsKey('All') ) {
        $ProfileName = Get-AWSCredential -ListProfileDetail | Select-Object -EXP ProfileName
        if ( $PSBoundParameters.ContainsKey('AWSPowerShell') ) {
            foreach ( $PN in $ProfileName ) {
                $Results += (Get-EC2Instance -ProfileName $PN -Region $Region).Instances
            }
        } else { $Results = Get-InstanceList -ProfileName $ProfileName -Region $Region }
    } else {
        if ( $PSBoundParameters.ContainsKey('AWSPowerShell') ) {
            foreach ( $PN in $ProfileName ) {
                $Results += (Get-EC2Instance -ProfileName $PN -Region $Region).Instances
            }
        } else { $Results = Get-InstanceList -ProfileName $ProfileName -Region $Region }
    }

    $Results
}
