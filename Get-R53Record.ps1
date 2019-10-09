#Requires -Module AWS.Tools.Route53

function Get-R53Record {
    <# =========================================================================
    .SYNOPSIS
        Get R53 DNS records
    .DESCRIPTION
        Get R53 Hosted zone DNS data for all "A" and "CNAME" records
    .PARAMETER ProfileName
        AWS Profile name
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
        [Parameter(Mandatory, HelpMessage = 'AWS Profile containing access key and secret')]
        [ValidateScript( { (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [Alias('Profile')]
        [string] $ProfileName,

        [Parameter(Mandatory, HelpMessage = 'Hosted zone name')]
        [ValidateNotNullOrEmpty()]
        [Alias('Zone', 'ZN')]
        [string] $ZoneName
    )

    Begin {
        # SET PROPERTIES TO GET
        $Properties = @('Type', 'Name', @{N = 'Value'; E = { $_.ResourceRecords.Value } }, 'TTL')

        # SET WHERE CLAUSE TO FILTER
        $Where = { $_.Type -in @('CNAME', 'A') }
    }

    Process {
        # GET HOSTED ZONE WITH GIVEN NAME
        $Zone = Get-R53HostedZoneList -ProfileName $ProfileName | Where-Object Name -EQ $ZoneName

        # GET ZONE -- THIS IS NOT REQUIRED AND MAY BE REMOVED
        #Get-R53HostedZone -Id $Zone.Id

        # GET DNS RECORDS FOR PROVIDED HOSTED ZONE
        $Records = Get-R53ResourceRecordSet -HostedZoneId $Zone.Id | Select-Object -ExpandProperty ResourceRecordSets
    }

    End {
        # RETURN RECORDS
        $Records | Where-Object $Where | Select-Object -Property $Properties
    }
}