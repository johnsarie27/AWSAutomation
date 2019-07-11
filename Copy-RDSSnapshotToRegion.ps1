function Copy-RDSSnapshotToRegion {
    <# =========================================================================
    .SYNOPSIS
        Copy RDS snapshot to another Region
    .DESCRIPTION
        Copy the latest RDS snapshot to another Region
    .PARAMETER ProfileName
        AWS Credential Profile Name
    .PARAMETER SourceRegion
        Region of existing RDS DB snapshot
    .PARAMETER DestinationRegion
        Destination Region to copy snapshot
    .INPUTS
        None.
    .OUTPUTS
        System.Object.
    .EXAMPLE
        PS C:\> Copy-RDSSnapshotToRegion -ProfileName MyProfile
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
        [Parameter(Mandatory, HelpMessage = 'AWS Credential Profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [Alias('SR')]
        [string[]] $ProfileName,

        [Parameter(HelpMessage = 'Region of existing RDS DB snapshot')]
        [ValidateSet({ (Get-AWSRegion).Region -contains $_ })]
        [Alias('SR')]
        [string] $SourceRegion = 'us-east-1',

        [Parameter(HelpMessage = 'Destination Region to copy snapshot')]
        [ValidateSet({ (Get-AWSRegion).Region -contains $_ })]
        [Alias('DR')]
        [string] $DestinationRegion = 'us-west-1'
    )

    Begin {
        # VALIDATE EXISTENCE OF PARAMS
        if ( !$SourceRegion -or !$DestinationRegion ) {
            Throw 'Source or Destination Region not found.'
        }
    }

    Process {
        foreach ( $p in $ProfileName ) {
            # SET PARAMETERS FOR AWS CALLS BELOW
            $srSplat = @{ ProfileName = 'esripsfedramp'; Region = $SourceRegion }
            $drSplat = @{ ProfileName = 'esripsfedramp'; Region = $DestinationRegion }

            # IMPORT REQUIRED MODULES
            Import-Module -Name AWSPowerShell.NetCore

            # GET DB INSTANCE
            $rdsDb = Get-RDSDBInstance @srSplat

            # GET SNAPSHOTS
            $snapParams = @{
                DBInstanceIdentifier = $rdsDb.DBInstanceIdentifier
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
                    Write-Output ('Failed to copy snapshot [{0}] to Region [{1}]' -f $snapshot.DBSnapshotIdentifier, $copyParams.Region)
                    Write-Output ('Error message: {0}' -f $_.Exception.Message)
                }
            }
            else {
                Write-Error ('No recent snapshots found for {0}' -f $snapshot.DBInstanceIdentifier)
            }
        }
    }
}
