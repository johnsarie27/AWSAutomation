function Copy-DBSnapshotToRegion {
    <# =========================================================================
    .SYNOPSIS
        Copy RDS snapshot to another Region
    .DESCRIPTION
        Copy the latest RDS snapshot to another Region
    .PARAMETER DBInstance
        AWS DBInstance object
    .PARAMETER Credential
        AWS Credential object
    .PARAMETER ProfileName
        AWS Credential Profile Name
    .PARAMETER DestinationRegion
        Destination Region to copy snapshot
    .INPUTS
        Amazon.RDS.Model.DBInstance.
    .OUTPUTS
        System.String.
    .EXAMPLE
        --- EXAMPLE 1 ---
        PS C:\> Copy-DBSnapshotToRegion -ProfileName MyProfile -DBInstance $db1
        Copies $db1 Instances in MyProfile account from us-east-1 to us-west-1

        --- EXAMPLE 2 ---
        PS C:\> $dbs = Get-RDSDBInstance -Region us-east-1
        PS C:\> Copy-DBSnapshotToRegion -DBInstance $dbs -Credential myCreds
        Copies $dbs to us-west-1 using myCreds
    .NOTES
        The "RDSDBCluster" cmdlets like "Get-RDSDBCluster" appear to be for other DBMS
    ========================================================================= #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'RDS DB Instance to copy')]
        [ValidateNotNullOrEmpty()]
        [Amazon.RDS.Model.DBInstance[]] $DBInstance,

        [Parameter(HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(HelpMessage = 'AWS Credential Profile name')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [string] $ProfileName,

        [Parameter(HelpMessage = 'Destination Region to copy snapshot')]
        [ValidateScript({ (Get-AWSRegion).Region -contains $_ })]
        [string] $DestinationRegion = 'us-west-1'
    )

    Begin {
        # VALIDATE EXISTENCE OF PARAMS
        if ( !$DestinationRegion ) { Throw 'Source or Destination Region not found.' }

        # SET PARAMETERS FOR AWS CALLS BELOW
        if ( $PSBoundParameters.ContainsKey('ProfileName') ) { $keys = @{ ProfileName = $ProfileName } }
        if ( $PSBoundParameters.ContainsKey('Credential') ) { $keys = @{ Credential = $Credential } }
    }

    Process {
        foreach ( $db in $DBInstance ) {
            # GET DB Instance Region
            $dbRegion = $db.DBInstanceArn -replace '^.+rds:([\w-]+):.+$', '$1'

            # GET SNAPSHOTS
            $snapParams = @{
                DBInstanceIdentifier = $db.DBInstanceIdentifier
                SnapshotType         = 'automated' #'manual', 'awsbackup'
                Region               = $dbRegion
            }
            $snapshot = (Get-RDSDBSnapshot @snapParams @keys | Sort-Object -Property SnapshotCreateTime -Descending)[0]

            # CHECK TO MAKE SURE THE SNAPSHOT IS NOT OLD
            if ( $snapshot.SnapshotCreateTime -gt (Get-Date).AddDays(-2) ) {
                # GET KMS KEY OF DR REGION
                foreach ( $i in (Get-KMSKeyList @keys -Region $DestinationRegion) ) {
                    $key = Get-KMSKey @keys -Region $DestinationRegion -KeyId $i.KeyId
                    if ( $key.Description -match 'master.+RDS' ) { $drKey = $key }
                }

                $copyParams = @{
                    CopyTag                    = $true
                    KmsKeyId                   = $drKey.Arn
                    SourceDBSnapshotIdentifier = $snapshot.DBSnapshotArn
                    TargetDBSnapshotIdentifier = $snapshot.DBSnapshotIdentifier.Replace('rds:', '')
                    SourceRegion               = $dbRegion
                    Region                     = $DestinationRegion
                    ErrorAction                = 'Stop'
                }

                try {
                    # THIS SUPPRESSES THE OUTPUT FROM THE NATIVE AWS CMDLET USING "| Out-Null" AS ITS NOT
                    # CURRENTLY NEEDED. THE OUTPUT ON THE NEXT LINE IS SUFFICIENT FOR THE BACKUP-DR SCENARIO
                    Copy-RDSDBSnapshot @copyParams @keys | Out-Null
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
