---
external help file: AWSAutomation-help.xml
Module Name: AWSAutomation
online version:
schema: 2.0.0
---

# Remove-LapsedAMI

## SYNOPSIS
Delete AMIs based on backup policy

## SYNTAX

```
Remove-LapsedAMI [-ProfileName] <String[]> [-Region] <String> [[-BackupSuffix] <String>]
 [[-RunAsTestOnly] <Boolean>] [[-MonthlyBackupDay] <Int32>] [[-WeeklyBackupDay] <String>]
 [[-DailyBackupRetentionPeriod] <Int32>] [[-WeeklyBackupRetentionPeriod] <Int32>]
 [[-MonthlyBackupRetentionPeriod] <Int32>] [<CommonParameters>]
```

## DESCRIPTION
The default use of this script is to scan all AMIs in a region with the suffix ".backup" and SIMULATE deleting any that are older than 7 days, excepting every Thursday, and the first of every month, for 6 months. actually delete AMIs, supply the parameter: -RunAsTestOnly $false

## EXAMPLES

### Example 1
```powershell
PS C:\> Remove-LapsedAMI -ProfileName 'myProfile' -region 'us-east-1'
```

This example shows the basic usage that SIMULATES deleting AMIs.

### Example 2
```powershell
PS C:\> Remove-LapsedAMI -ProfileName 'myProfile' -region 'us-east-1' -RunAsTestOnly $false
```

This example ACTUALLY deletes the AMIS.

### Example 3
```powershell
PS C:\> Remove-LapsedAMI -ProfileName 'myProfile' -region 'us-east-1' -BackupSuffix ''
```

To search for AMIs that have no suffix (don't end in .backup), run this command.

## PARAMETERS

### -BackupSuffix
Backup suffix

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DailyBackupRetentionPeriod
Number of days to retain daily backups

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MonthlyBackupDay
Day of month designated for monthly backups

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MonthlyBackupRetentionPeriod
Number of days to retain monthly backups

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileName
AWS Profile containing access keys

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Profile

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Region
AWS Region

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: us-east-1, us-east-2, us-west-1, us-west-2

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RunAsTestOnly
Run in test mode only

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WeeklyBackupDay
Day of week designated for weekly backups

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WeeklyBackupRetentionPeriod
Number of days to retain weekly backups

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
### System.ValueType.Int32
### System.ValueType.Boolean

## OUTPUTS

### System.String
## NOTES

## RELATED LINKS
