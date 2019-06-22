function Deploy-Instance {
    <# =========================================================================
    .SYNOPSIS
        Deploy new EC2 instance
    .DESCRIPTION
        Deploy new EC2 instance with program-compliant values and settings
    .PARAMETER ProfileName
        AWS Credential Profile name
    .PARAMETER Region
        AWS Region
    .PARAMETER AmiId
        AWS AMI ID
    .PARAMETER Name
        Name for new EC2 instance
    .PARAMETER SubnetId
        Subnet ID for new EC2 instance
    .PARAMETER SecurityGroupId
        Security Group ID for new EC2 instance
    .PARAMETER Type
        AWS EC2 Instance Type
    .PARAMETER PassThru
        Return EC2 Instance Object
    .INPUTS
        System.String.
    .OUTPUTS
        None.
    .EXAMPLE
        PS C:\> Deploy-Instance -PN MyAcc -Name MyInstance -SN sn-12u98732 -SG sg-19823894
        Launch new EC2 instance in us-east-1 with name tag MyInstance
    .NOTES
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, HelpMessage = 'AWS Profile')]
        [ValidateScript( { (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [Alias('PN')]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'AWS Region')]
        [ValidateSet('us-east-1', 'us-east-2', 'us-west-1', 'us-west-2')]
        [Alias('R')]
        [String] $Region = 'us-east-1',

        [Parameter(HelpMessage = 'EC2 AMI ID')]
        [ValidatePattern('^ami-\w{8,17}$')]
        [Alias('A')]
        [string] $AmiId = 'ami-e80e2993',

        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'New EC2 instance name tag')]
        [ValidatePattern('^\w{3}(PRD|STG)(AGS|PTL|HST|DS)\d{2}$')]
        [Alias('N')]
        [string[]] $Name,

        [Parameter(Mandatory, HelpMessage = 'EC2 subnet')]
        [ValidatePattern('^subnet-\w{8,17}$')]
        [Alias('SN')]
        [string] $SubnetId,

        [Parameter(Mandatory, HelpMessage = 'New EC2 instance name tag')]
        [ValidatePattern('^sg-\w{8,17}$')]
        [Alias('SG')]
        [string[]] $SecurityGroupId,

        [Parameter(HelpMessage = 'EC2 instance type')]
        [ValidateSet('m4.xlarge', 'm4.2xlarge')]
        [Alias('T')]
        [string] $Type = 'm4.xlarge',

        [Parameter(HelpMessage = 'Return EC2 Instance object')]
        [Alias('PT')]
        [switch] $PassThru
    )

    Begin {
        # SET INSTANCE PARAMS
        $instanceParams = @{
            ProfileName          = $ProfileName
            Region               = $Region
            ImageId              = $AmiId
            MinCount             = 1
            MaxCount             = 1
            InstanceType         = $Type
            SecurityGroupId      = $SecurityGroupId
            SubnetId             = $SubnetId
            InstanceProfile_Name = 'roleMemberServer'
        }
    }

    Process {
        foreach ( $n in $Name ) {
            # LAUNCH NEW INSTANCE
            $instance = New-EC2Instance @instanceParams

            # SET TAG DATA
            $role = switch -Regex ( $n ) {
                { $_ -match '^\w{6}AGS\d{2}$' } { 'ArcGIS Server' }
                { $_ -match '^\w{6}HST\d{2}$' } { 'ArcGIS Server (Hosted)' }
                { $_ -match '^\w{6}PTL\d{2}$' } { 'Portal for ArcGIS' }
                { $_ -match '^\w{6}DS\d{2}$' } { 'DataStore for ArcGIS' }
            }

            # ADD TAGS
            $tagScheme = @{
                Name   = $n
                Agency = $n.Substring(0, 3)
                Role   = $role
            }

            foreach ( $i in $tagScheme.GetEnumerator() ) {
                <# $tag = New-Object -TypeName Amazon.EC2.Model.Tag
                $tag.Key = $i.Name
                $tag.Value = $i.Value #>
                $tag = [Amazon.EC2.Model.Tag] @{ Key = $i.Name; Value = $i.Value }
                New-EC2Tag -Resource $instance.Instances.InstanceId -Tag $tag @splat
            }

            # RETURN INSTANCE OBJECT
            if ( $PSBoundParameters.ContainsKey('PassThru') ) { $instance }
        }
    }
}
