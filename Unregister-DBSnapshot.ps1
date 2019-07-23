function Unregister-DBSnapshot {
    <# =========================================================================
    .SYNOPSIS
        Copy RDS snapshot to another Region
    .DESCRIPTION
        Copy the latest RDS snapshot to another Region
    .PARAMETER DBInstance
        AWS DBInstance object
    .PARAMETER ProfileName
        AWS Credential Profile Name
    .PARAMETER Region
        Region of existing RDS DB snapshot
    .INPUTS
        Amazon.RDS.Model.DBInstance.
    .OUTPUTS
        System.String.
    .EXAMPLE
        PS C:\> Unregister-DBSnapshot -ProfileName MyProfile
        Copies all RDS DB Instances in MyProfile account from us-east-1 to us-west-1
    .NOTES
        The "RDSDBCluster" cmdlets like "Get-RDSDBCluster" appear to be for other DBMS
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(ValueFromPipeline, HelpMessage = 'RDS DB Instance to copy')]
        [ValidateNotNullOrEmpty()]
        [Amazon.RDS.Model.DBInstance[]] $DBInstance,

        [Parameter(Mandatory, HelpMessage = 'AWS Credential Profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'Region of existing RDS DB snapshot')]
        [ValidateSet({ (Get-AWSRegion).Region -contains $_ })]
        [string] $Region = 'us-west-1',

        [int] $Age = 90
    )

    Begin {
        # VALIDATE EXISTENCE OF PARAMS
        if ( !$Region ) { Throw 'Region not found.' }

        # SET PARAMETERS FOR AWS CALLS BELOW
        $splat = @{ ProfileName = $ProfileName; Region = $SourceRegion }
        
        # GET DB INSTANCE
        if ( -not $PSBoundParameters.ContainsKey('DBInstance') ) {
            $DBInstance = Get-RDSDBInstance @splat
        }
    }

    Process {
        foreach ( $db in $DBInstance ) {
            # GET SNAPSHOTS
            $snapParams = @{
                DBInstanceIdentifier = $db.DBInstanceIdentifier
                SnapshotType         = 'automated' #'manual', 'awsbackup'
            }
            $snapshot = Get-RDSDBSnapshot @snapParams @splat

            # REMOVE "OLD" SNAPSHOTS
            foreach ( $ss in $snapshot ) {
                if ( $ss.SnapshotCreateTime -lt (Get-Date).AddDays(-$Age) ) {
                    Remove-RDSDBSnapshot -DBSnapshotIdentifier $ss.DBSnapshotIdentifier
                }
            }

        }
    }
}
