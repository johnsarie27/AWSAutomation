#Requires -Modules AWS.Tools.EC2

function Remove-LapsedAMI {
    <# =============================================================================
    .SYNOPSIS
        Delete AMIs based on backup policy
    .DESCRIPTION
        The default use of this script is to scan all AMIs in a region with the
        suffix ".backup" and SIMULATE deleting any that are older than 7 days,
        excepting every Thursday, and the first of every month, for 6 months.
        actually delete AMIs, supply the parameter: -RunAsTestOnly $false
    .PARAMETER ProfileName
        AWS Credential Profile name
    .PARAMETER Credential
        AWS Credential Object
    .PARAMETER Region
        AWS Region
    .PARAMETER BackupSuffix
        Backup suffix
    .PARAMETER RunAsTestOnly
        Run in test mode only, no destruction
    .PARAMETER MonthlyBackupDay
        What day of the month do you want to define as your monthly backups?
    .PARAMETER WeeklyBackupDay
        What day of the week do you want to define as your weekly backup?
    .PARAMETER DailyBackupRetentionPeriod
        How far back do you want to keep daily backups?
    .PARAMETER WeeklyBackupRetentionPeriod
        How far back do you want to keep weekly backups?
    .PARAMETER MonthlyBackupRetentionPeriod
        How far back do you want to keep monthly backups?
    .INPUTS
        System.String.
        System.ValueType.Boolean.
        System.ValueType.Int.
    .OUTPUTS
        System.String.
    .EXAMPLE
        PS C:\> Remove-LapsedAMI -ProfileName 'myProfile' -region 'us-east-1'

        This example shows the basic usage that SIMULATES deleting AMIs.
    .EXAMPLE
        PS C:\> Remove-LapsedAMI -ProfileName 'myProfile' -region 'us-east-1' -RunAsTestOnly $false

        This example ACTUALLY deletes the AMIS.
    .EXAMPLE
        PS C:\> Remove-LapsedAMI -ProfileName 'myProfile' -region 'us-east-1' -BackupSuffix ''

        To search for AMIs that have no suffix (don't end in .backup), run this command.
    .NOTES
        It is also possible to search on using a different retention based on the following parameters:

        -DailyBackupRetentionPeriod 7       #How far back do you want to keep daily backups?
        -WeeklyBackupRetentionPeriod 31     #How far back do you want to keep weekly backups?
        -WeeklyBackupDay 'Thursday'         #What day of the week do you want to define as your weekly backup?
        -MonthlyBackupRetentionPeriod 180   #How far back do you want to keep monthly backups?
        -MonthyBackupDay 1                  #What day of the month do you want to define as your monthly backups?
    ============================================================================= #>
    Param(
        [Parameter(Mandatory, ValueFromPipeline, HelpMessage = 'AWS Profile containing access keys')]
        [ValidateScript({ (Get-AWSCredential -ListProfileDetail).ProfileName -contains $_ })]
        [ValidateNotNullOrEmpty()]
        [Alias('Profile')]
        [string[]] $ProfileName,

        [Parameter(HelpMessage = 'AWS Credential Object')]
        [ValidateNotNullOrEmpty()]
        [Amazon.Runtime.AWSCredentials] $Credential,

        [Parameter(Mandatory, HelpMessage = 'AWS Region')]
        [ValidateScript( { (Get-AWSRegion).Region -contains $_ })]
        [string] $Region,

        [Parameter(HelpMessage = 'Backup suffix')]
        [AllowEmptyString()]
        [string] $BackupSuffix = ".backup",

        [Parameter(HelpMessage = 'Run in test mode only')]
        [boolean] $RunAsTestOnly = $true,

        [Parameter(HelpMessage = 'Day of month designated for monthly backups')]
        [ValidateRange(1,31)]
        [int] $MonthlyBackupDay = 1,

        [Parameter(HelpMessage = 'Day of week designated for weekly backups')]
        [ValidateSet('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday')]
        [string] $WeeklyBackupDay = 'Thursday',

        [Parameter(HelpMessage = 'Number of days to retain daily backups')]
        [int] $DailyBackupRetentionPeriod = 8,

        [Parameter(HelpMessage = 'Number of days to retain weekly backups')]
        [int] $WeeklyBackupRetentionPeriod = 31,

        [Parameter(HelpMessage = 'Number of days to retain monthly backups')]
        [int] $MonthlyBackupRetentionPeriod = 180
    )

    Begin {
        # SET VARS
        $Output = ''

        function Unregister-EC2AmisandSnapshot {
            Param (
                [Parameter(Mandatory)] [string] $ProfileName,
                [Parameter(Mandatory)] [string] $Region,
                [boolean] $RunAsTestOnly = $true,
                # PASS $false FOR THIS PARAMETER TO ACTUALLY DELETE AMIS AND ASSOCIATED SNAPSHOTS.
                # BY DEFAULT THE SCRIPT RUNS IN TEST MODE ONLY WHICH WILL PERFORM ALL FUNCTIONS
                # (INCLUDING NOTIFICATIONS) BUT WILL NOT ACTUALLY DELETE ANYTHING.
                [Parameter(Mandatory)] $amisTargetedForDeletion
            )

            # THE CONTENT WITHIN THIS BLOCK IS DESTRUCTIVE. ONLY EXECUTE NEXT LINE IF $RUNASTESTONLY = $false
            if ( $RunAsTestOnly -eq $false ) {

                foreach ($ami in $amisTargetedForDeletion) {
                    $amiSnapshots = @($ami.BlockDeviceMapping.ebs.snapshotid)
                    Unregister-EC2Image -ImageId $ami.ImageId -Region $Region -ProfileName $ProfileName
                    Start-Sleep 10
                    foreach ($snapshot in $amiSnapshots) {
                        Remove-EC2Snapshot -Region $Region -SnapshotId $snapshot -ProfileName $ProfileName -Force
                    }
                }
            }
        }
    }

    Process {
        # LOOP ALL PROFILES
        foreach ( $Name in $ProfileName ) {
            # SET SPLATTER TABLE
            $Splat = @{ ProfileName = $Name; Region = $Region; Owner = 'self' }

            #TARGET DAILY IMAGES OLDER THAN A WEEK, NEWER THAN A MONTH, EXCLUDING MONTHLY BACKUPS AND WEEKLY BACKUPS, WITH NAMES ENDING IN *.backup.
            $DailyImagesToDelete = Get-EC2Image @Splat | Where-Object {
                [datetime]::Parse($_.CreationDate).DayofWeek -ne $WeeklyBackupDay -and `
                [datetime]::Parse($_.CreationDate).Day -ne $MonthlyBackupDay -and `
                [datetime]::Parse($_.CreationDate) -gt (Get-Date).AddDays(-$WeeklyBackupRetentionPeriod) -and `
                [datetime]::Parse($_.CreationDate) -lt (Get-Date).AddDays(-$DailyBackupRetentionPeriod) -and `
                $_.Name -like '*' + $BackupSuffix
            }

            if ( $DailyImagesToDelete ) {
                $Output += "`n`nDeleting Daily Images: `n"
                $DailyImagesToDelete | ForEach-Object -Process {
                    $Output += ($_.Name + "; " + [datetime]::parse($_.CreationDate).DateTime + "`n")
                }
            }

            #TARGET IMAGES OLDER THAN A MONTH, NEWER THAN A SIX MONTHS, EXCLUDING MONTHLY BACKUPS, WITH NAMES ENDING IN *.backup.
            $WeeklyImagesToDelete = Get-EC2Image @Splat | Where-Object {
                [datetime]::Parse($_.CreationDate).Day -ne $MonthlyBackupDay -and `
                [datetime]::Parse($_.CreationDate) -lt (Get-Date).AddDays(-$WeeklyBackupRetentionPeriod) -and `
                [datetime]::Parse($_.CreationDate) -gt (Get-Date).AddDays(-$MonthlyBackupRetentionPeriod) -and `
                $_.Name -like '*' + $BackupSuffix
            }

            if ( $WeeklyImagesToDelete ) {
                $Output += "`n`nDeleting Weekly Images: `n"
                $WeeklyImagesToDelete | ForEach-Object -Process {
                    $Output += ($_.Name + "; " + [datetime]::parse($_.CreationDate).DateTime + "`n")
                }
            }

            #TARGET IMAGES OLDER THAN 6 MONTHS, WITH NAMES ENDING IN *.backup.
            $MonthlyImagesToDelete = Get-EC2Image @Splat | Where-Object {
                [datetime]::Parse($_.CreationDate) -lt (Get-Date).AddDays(-$MonthlyBackupRetentionPeriod) -and `
                $_.Name -like '*' + $BackupSuffix
            }

            if ( $MonthlyImagesToDelete ) {
                $Output += "`n`nDeleting Monthly Images: `n"
                $MonthlyImagesToDelete | ForEach-Object -Process {
                    $Output += ($_.Name + "; " + [datetime]::parse($_.CreationDate).DateTime + "`n")
                }
            }

            # SETUP SPLATTER TABLE FOR PARAMETERS
            $Splat.Remove('Owner'); $Splat['bolRunAsTestOnly'] = $RunAsTestOnly

            # UNREGISTER AMIS
            if ( $DailyImagesToDelete ) { Unregister-EC2AmisandSnapshot @Splat -amisTargetedForDeletion $DailyImagesToDelete }
            if ( $WeeklyImagesToDelete ) { Unregister-EC2AmisandSnapshot @Splat -amisTargetedForDeletion $WeeklyImagesToDelete }
            if ( $MonthlyImagesToDelete ) { Unregister-EC2AmisandSnapshot @Splat -amisTargetedForDeletion $MonthlyImagesToDelete }
        }
    }

    End {
        # RETURN OUTPUT
        $Output
    }
}
