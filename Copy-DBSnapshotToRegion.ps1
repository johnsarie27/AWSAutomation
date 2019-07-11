function Copy-DBSnapshotToRegion {
    <# =========================================================================
    .SYNOPSIS
        Copy RDS snapshot to another Region
    .DESCRIPTION
        Copy the latest RDS snapshot to another Region
    .PARAMETER DBInstance
        AWS DBInstance object
    .PARAMETER ProfileName
        AWS Credential Profile Name
    .PARAMETER SourceRegion
        Region of existing RDS DB snapshot
    .PARAMETER DestinationRegion
        Destination Region to copy snapshot
    .INPUTS
        Amazon.RDS.Model.DBInstance.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Copy-DBSnapshotToRegion -ProfileName MyProfile
        Explanation of what the example does
    .NOTES
        The "RDSDBCluster" cmdlets like "Get-RDSDBCluster" appear to be for other DBMS
        Permissions added:
        - AmazonRDSFullAccess
        - policyKMSFullAccess
        # NEED SOME CODE TO CLEAN UP "OLD" BACKUPS
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
        [string] $SourceRegion = 'us-east-1',

        [Parameter(HelpMessage = 'Destination Region to copy snapshot')]
        [ValidateSet({ (Get-AWSRegion).Region -contains $_ })]
        [string] $DestinationRegion = 'us-west-1'
    )

    Begin {
        # VALIDATE EXISTENCE OF PARAMS
        if ( !$SourceRegion -or !$DestinationRegion ) {
            Throw 'Source or Destination Region not found.'
        }

        # SET PARAMETERS FOR AWS CALLS BELOW
        $srSplat = @{ ProfileName = $ProfileName; Region = $SourceRegion }
        $drSplat = @{ ProfileName = $ProfileName; Region = $DestinationRegion }

        # GET DB INSTANCE
        if ( -not $PSBoundParameters.ContainsKey('DBInstance') ) {
            $DBInstance = Get-RDSDBInstance @srSplat
        }
    }

    Process {
        foreach ( $db in $DBInstance ) {
            # GET SNAPSHOTS
            $snapParams = @{
                DBInstanceIdentifier = $db.DBInstanceIdentifier
                SnapshotType         = 'automated' #'manual', 'awsbackup'
            }
            $snapshot = Get-RDSDBSnapshot @snapParams @srSplat | Select-Object -Last 1

            # COPY SNAPSHOT TO DR REGION
            if ( $snapshot.SnapshotCreateTime -gt (Get-Date).AddDays(-2) ) {
                # GET KMS KEY OF DR REGION
                foreach ( $i in (Get-KMSKeyList @drSplat) ) {
                    $key = Get-KMSKey @drSplat -KeyId $i.KeyId
                    if ( $key.Description -match 'master.+RDS' ) { $drKey = $key }
                }

                $copyParams = @{
                    CopyTag                    = $true
                    KmsKeyId                   = $drKey.Arn
                    SourceDBSnapshotIdentifier = $snapshot.DBSnapshotArn
                    TargetDBSnapshotIdentifier = $snapshot.DBSnapshotIdentifier.Replace('rds:', '')
                    SourceRegion               = $SourceRegion
                    ProfileName                = $srSplat.ProfileName
                    Region                     = $DestinationRegion
                    ErrorAction                = 'Stop'
                }
                try {
                    Copy-RDSDBSnapshot @copyParams
                    Write-Output ('Copied snapshot [{0}] to Region [{1}]' -f $snapshot.DBSnapshotIdentifier, $copyParams.Region)
                }
                catch {
                    $vars = @($snapshot.DBSnapshotIdentifier, $copyParams.Region, $_.Exception.Message)
                    Write-Error ('Failed to copy snapshot [{0}] to Region [{1}]. Error message: {2}' -f $vars)
                }
            }
            else {
                Write-Warning ('No recent snapshots found for {0}' -f $snapshot.DBInstanceIdentifier)
            }
        }
    }
}
