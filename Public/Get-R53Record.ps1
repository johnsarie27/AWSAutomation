function Get-R53Record {
    <# =========================================================================
    .SYNOPSIS
        Get R53 DNS records
    .DESCRIPTION
        Get R53 Hosted zone DNS data for all "A" and "CNAME" records
    .PARAMETER ProfileName
        AWS Profile name
    .PARAMETER Credential
        AWS Credential Object
    .PARAMETER ZoneName
        AWS R53 Hosted zone name
    .INPUTS
        None.
    .OUTPUTS
        System.Object[].
    .EXAMPLE
        PS C:\> Get-R53Record -ProfileName MyProfile -ZoneName 'myDomain.com.'
        Get all "A" and "CNAME" records for the zone 'myDomain.com.'
    .NOTES
        General notes
    ========================================================================= #>

    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = 'AWS Profile containing access key and secret')]
        [ValidateScript( { (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [Alias('Profile')]
        [System.String] $ProfileName,

        [Parameter(HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(Mandatory, HelpMessage = 'Hosted zone name')]
        [ValidateNotNullOrEmpty()]
        [Alias('Zone', 'ZN')]
        [System.String] $ZoneName
    )

    Begin {
        # SET PROPERTIES TO GET
        $Properties = @('Type', 'Name', @{N = 'Value'; E = { $_.ResourceRecords.Value } }, 'TTL')

        # SET WHERE CLAUSE TO FILTER
        $Where = { $_.Type -in @('CNAME', 'A') }

        # SET AUTHENTICATION
        if ( $PSBoundParameters.ContainsKey('ProfileName') ) { $awsParams = @{ ProfileName = $ProfileName } }
        if ( $PSBoundParameters.ContainsKey('Credential') ) { $awsParams = @{ Credential = $Credential } }
    }

    Process {
        # GET HOSTED ZONE WITH GIVEN NAME
        $zone = Get-R53HostedZoneList @awsParams | Where-Object Name -EQ $ZoneName

        # GET ZONE -- THIS IS NOT REQUIRED AND MAY BE REMOVED
        #Get-R53HostedZone -Id $zone.Id

        # GET DNS RECORDS FOR PROVIDED HOSTED ZONE
        $awsParams['HostedZoneId'] = $zone.Id
        $records = (Get-R53ResourceRecordSet @awsParams).ResourceRecordSets
    }

    End {
        # RETURN RECORDS
        $records | Where-Object $Where | Select-Object -Property $Properties
    }
}