function Remove-LapsedAMI {
    <# =============================================================================
    .SYNOPSIS
        Delete AMIs based on backup policy
    .DESCRIPTION
        The default use of this script is to scan all AMIs in a region with the
        suffix ".backup" and SIMULATE deleting any that are older than 7 days,
        excepting every Thursday, and the first of every month, for 6 months.  
        actually delete AMIs, supply the parameter: -RunAsTestOnly $false
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
        [Parameter(Mandatory)] [string] $ProfileName,
        [Parameter(Mandatory)] [string] $Region,
        [AllowEmptyString()] [string] $BackupSuffix = ".backup",
        [boolean] $RunAsTestOnly = $true,
        [int] $MonthlyBackupDay = 1,
        [string] $WeeklyBackupDay = 'Thursday',
        [int] $DailyBackupRetentionPeriod = 8,
        [int] $WeeklyBackupRetentionPeriod = 31,
        [int] $MonthlyBackupRetentionPeriod = 180
    )

    Begin {

        # SET VARS
        $Output = ''

        function Unregister-EC2AmisandSnapshot {
            Param (
                [Parameter(Mandatory)] [string] $ProfileName,
                [Parameter(Mandatory)] [string] $Region,
                [boolean] $bolRunAsTestOnly = $true,
                # PASS $FALSE FOR THIS PARAMETER TO ACTUALLY DELETE AMIS AND ASSOCIATED SNAPSHOTS.
                # BY DEFAULT THE SCRIPT RUNS IN TEST MODE ONLY WHICH WILL PERFORM ALL FUNCTIONS
                # (INCLUDING NOTIFICATIONS) BUT WILL NOT ACTUALLY DELETE ANYTHING.
                [Parameter(Mandatory)] $amisTargetedForDeletion
            )
    
            # THE CONTENT WITHIN THIS BLOCK IS DESTRUCTIVE. ONLY EXECUTE NEXT LINE IF $RUNASTESTONLY = $false
            if ($bolRunAsTestOnly -eq $false) {
        
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

        #TARGET DAILY IMAGES OLDER THAN A WEEK, NEWER THAN A MONTH, EXCLUDING MONTHLY BACKUPS AND WEEKLY BACKUPS, WITH NAMES ENDING IN *.backup.
        $DailyImagesToDelete = Get-EC2Image -ProfileName $ProfileName -Region $Region -Owner 'self' | `
        Where-Object {[datetime]::Parse($_.CreationDate).DayofWeek -ne $WeeklyBackupDay `
            -and [datetime]::Parse($_.CreationDate).Day -ne $MonthlyBackupDay `
            -and [datetime]::Parse($_.CreationDate) -gt (Get-Date).AddDays(-$WeeklyBackupRetentionPeriod) `
            -and [datetime]::Parse($_.CreationDate) -lt (Get-Date).AddDays(-$DailyBackupRetentionPeriod) `
            -and $_.Name -like '*' + $BackupSuffix}

        $Output += "`n`nDeleting Daily Images: `n"
        foreach ($image in $DailyImagesToDelete) {$Output += ($image.Name + "; " + [datetime]::parse($image.CreationDate).DateTime + "`n")}


        #TARGET IMAGES OLDER THAN A MONTH, NEWER THAN A SIX MONTHS, EXCLUDING MONTHLY BACKUPS, WITH NAMES ENDING IN *.backup.
        $WeeklyImagesToDelete = Get-EC2Image -ProfileName $ProfileName -Region $Region -Owner 'self' | `
        Where-Object {[datetime]::Parse($_.CreationDate).Day -ne $MonthlyBackupDay `
            -and ([datetime]::Parse($_.CreationDate) -lt (Get-Date).AddDays(-$WeeklyBackupRetentionPeriod)) `
            -and ([datetime]::Parse($_.CreationDate) -gt (Get-Date).AddDays(-$MonthlyBackupRetentionPeriod)) `
            -and $_.Name -like '*' + $BackupSuffix}

        $Output += "`n`nDeleting Weekly Images: `n"
        foreach ($image in $WeeklyImagesToDelete) {$Output += ($image.Name + "; " + [datetime]::parse($image.CreationDate).DateTime + "`n")}


        #TARGET IMAGES OLDER THAN 6 MONTHS, WITH NAMES ENDING IN *.backup.
        $MonthlyImagesToDelete = Get-EC2Image -ProfileName $ProfileName -Region $Region -Owner 'self' | `
        Where-Object {([datetime]::Parse($_.CreationDate) -lt (Get-Date).AddDays(-$MonthlyBackupRetentionPeriod)) `
            -and $_.Name -like '*' + $BackupSuffix}

        $Output += "`n`nDeleting Monthly Images: `n"
        foreach ($image in $MonthlyImagesToDelete) {$Output += ($image.Name + "; " + [datetime]::parse($image.CreationDate).DateTime + "`n")}

        # SETUP SPLATTER TABLE FOR PARAMETERS
        $Splat = @{ Region = $Region; ProfileName = $ProfileName; bolRunAsTestOnly = $RunAsTestOnly }
        
        # UNREGISTER AMIS
        if ( $null -ne $DailyImagesToDelete ) { Unregister-EC2AmisandSnapshot @Splat -amisTargetedForDeletion $DailyImagesToDelete }
        if ( $null -ne $WeeklyImagesToDelete ) { Unregister-EC2AmisandSnapshot @Splat -amisTargetedForDeletion $WeeklyImagesToDelete }
        if ($null -ne $MonthlyImagesToDelete ) { Unregister-EC2AmisandSnapshot @Splat -amisTargetedForDeletion $MonthlyImagesToDelete }
    }

    End {
        # RETURN OUTPUT
        $Output
    }
}