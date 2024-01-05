function Unregister-DbSnapshot {
    <#
    .SYNOPSIS
        Delete RDS snapshot
    .DESCRIPTION
        Delete RDS snapshot(s) older than provided age
    .PARAMETER DBInstance
        AWS DBInstance object
    .PARAMETER ProfileName
        AWS Credential Profile Name
    .PARAMETER Credential
        AWS Credential Object
    .PARAMETER Region
        Region of existing RDS DB snapshot
    .PARAMETER Age
        Age (in days) past which the snapshot(s) should be deleted
    .INPUTS
        Amazon.RDS.Model.DBInstance.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Unregister-DBSnapshot -ProfileName MyProfile
        Deletes all RDS DB Snapshots in MyProfile account from us-east-1
    .NOTES
        General notes
    #>
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline, HelpMessage = 'RDS DB Instance to copy')]
        [ValidateNotNullOrEmpty()]
        [Amazon.RDS.Model.DBInstance[]] $DBInstance,

        [Parameter(HelpMessage = 'AWS Credential Profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(HelpMessage = 'Region of existing RDS DB snapshot')]
        [ValidateSet({ (Get-AWSRegion).Region -contains $_ })]
        [string] $Region,

        [Parameter(HelpMessage = 'Age (in days) past which the snapshot will be deleted')]
        [int] $Age = 90
    )

    Begin {
        # VALIDATE EXISTENCE OF PARAMS
        if ( !$Region ) { Throw 'Region not found.' }

        # SET PARAMETERS FOR AWS CALLS BELOW
        $awsParams = @{ Region = $Region }

        if ( $PSBoundParameters.ContainsKey('ProfileName') ) { $awsParams['ProfileName'] = $ProfileName }
        if ( $PSBoundParameters.ContainsKey('Credential') ) { $awsParams['Credential'] = $Credential }

        # GET DB INSTANCE
        if ( -not $PSBoundParameters.ContainsKey('DBInstance') ) {
            $DBInstance = Get-RDSDBInstance @awsParams
        }
    }

    Process {
        foreach ( $db in $DBInstance ) {
            # GET SNAPSHOTS
            $snapshotParams = @{
                DBInstanceIdentifier = $db.DBInstanceIdentifier
                SnapshotType         = 'manual' # 'automated' , 'awsbackup'
            }

            $snapshot = Get-RDSDBSnapshot @awsParams @snapshotParams

            # REMOVE "OLD" SNAPSHOTS
            foreach ( $ss in $snapshot ) {

                if ( $ss.SnapshotCreateTime -lt (Get-Date).AddDays(-$Age) ) {
                    $removeParams = @{
                        DBSnapshotIdentifier = $ss.DBSnapshotIdentifier
                        Force                = $true
                    }

                    Remove-RDSDBSnapshot @awsParams @removeParams
                    #$ss | Select-Object -Property DBSnapshotIdentifier, SnapshotCreateTime
                }
            }
        }
    }
}
