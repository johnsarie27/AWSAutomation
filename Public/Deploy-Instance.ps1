#Requires -Modules @{ ModuleName = 'AWS.Tools.EC2'; ModuleVersion = '4.0.1.1' }

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
    .PARAMETER UserData
        UserData as string (not encoded)
    .PARAMETER PassThru
        Return EC2 Instance Object
    .INPUTS
        System.String.
    .OUTPUTS
        Amazon.EC2.Model.Reservation.
    .EXAMPLE
        PS C:\> Deploy-Instance -PN MyAcc -Name MyInstance -SN sn-12u98732 -SG sg-19823894
        Launch new EC2 instance in us-east-1 with name tag MyInstance
    .NOTES
    ========================================================================= #>
    [CmdletBinding()]
    [OutputType([Amazon.EC2.Model.Reservation[]])]
    Param(
        [Parameter(Mandatory, HelpMessage = 'AWS Profile')]
        [ValidateScript( { (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'AWS Region')]
        [ValidateScript( { (Get-AWSRegion).Region -contains $_ })]
        [String] $Region = 'us-east-1',

        [Parameter(HelpMessage = 'EC2 AMI ID')]
        [ValidatePattern('^ami-\w{8,17}$')]
        [string] $AmiId = 'ami-e80e2993',

        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'New EC2 instance name tag')]
        #[ValidatePattern('^\w{3}(PRD|STG)(AGS|PTL|HST|DS|SQL|QRM)\d{2}$')]
        [ValidateNotNullOrEmpty()]
        [string[]] $Name,

        [Parameter(Mandatory, HelpMessage = 'EC2 subnet')]
        [ValidatePattern('^subnet-\w{8,17}$')]
        [string] $SubnetId,

        [Parameter(Mandatory, HelpMessage = 'New EC2 instance name tag')]
        [ValidatePattern('^sg-\w{8,17}$')]
        [string[]] $SecurityGroupId,

        [Parameter(HelpMessage = 'EC2 instance type')]
        [ValidateNotNullOrEmpty()]
        [string] $Type = 'm4.xlarge',

        [Parameter(HelpMessage = 'User data string')]
        [string] $UserData,

        [Parameter(HelpMessage = 'Return EC2 Instance object')]
        [switch] $PassThru
    )

    Begin {
        # VALIDATE INSTANCE TYPE
        if ( $Type -notin (Get-EC2InstanceType -ProfileName $ProfileName -Region $Region).InstanceType ) {
            Throw 'Invalid instance type provided.'
        }

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

        # ENCODE USER DATA AND ADD TO PARAMETERS
        if ( $PSBoundParameters.ContainsKey('UserData') ) {
            $bytes = [System.Text.Encoding]::Unicode.GetBytes($UserData)
            $userDataB64 = [Convert]::ToBase64String($bytes)
            $instanceParams['UserData'] = $userDataB64
        }
    }

    Process {
        foreach ( $n in $Name ) {
            # LAUNCH NEW INSTANCE
            $instance = New-EC2Instance @instanceParams

            # SET TAG DATA
            $role = switch -Regex ( $n ) {
                '^\w{6}AGS\d{2}$' { 'ArcGIS Server' }
                '^\w{6}HST\d{2}$' { 'ArcGIS Server (Hosted)' }
                '^\w{6}PTL\d{2}$' { 'Portal for ArcGIS' }
                '^\w{6}SQL\d{2}$' { 'SQL Server' }
                '^\w{6}DS\d{2}$'  { 'DataStore for ArcGIS' }
                default           { 'Unknown role' }
            }

            # ADD TAGS
            $tagScheme = @{
                Agency = $n.Substring(0, 3)
                Role   = $role
                Name   = $n
            }

            foreach ( $i in $tagScheme.GetEnumerator() ) {
                <# $tag = New-Object -TypeName Amazon.EC2.Model.Tag
                $tag.Key = $i.Name
                $tag.Value = $i.Value #>
                $tag = [Amazon.EC2.Model.Tag] @{ Key = $i.Name; Value = $i.Value }
                New-EC2Tag -Resource $instance.Instances.InstanceId -Tag $tag @splat
            }

            # RETURN INSTANCE OBJECT
            if ( $PSBoundParameters.ContainsKey('PassThru') ) { $instance.Instances }
        }
    }
}
