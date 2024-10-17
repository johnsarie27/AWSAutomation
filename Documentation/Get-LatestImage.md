# Get-LatestImage

## SYNOPSIS
Get latest image(s) for an EC2 instance

## SYNTAX

```
Get-LatestImage [-NameTag] <String> [[-BackupDays] <Int32>] [-ProfileName] <String> [-Region] <String>
 [<CommonParameters>]
```

## DESCRIPTION
Get the latest image(s) for an EC2 instance from a specified number of days ago

## EXAMPLES

### EXAMPLE 1
```
Get-LatestImage @commonParams -NameTag 'MyInstance' -BackupDays 3
Returns the latest image(s) for the instance 'MyInstance' from the last 3 days
```

## PARAMETERS

### -NameTag
EC2 Instance name tag value

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BackupDays
Backup days to output

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 3
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileName
AWS Profile

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Region
AWS Region

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None.
## OUTPUTS

### System.Object.
## NOTES
Name:     Get-LatestImage
Author:   Justin Johns
Version:  0.1.0 | Last Edit: 2024-10-17
- Version history is captured in repository commit history
Comments: \<Comment(s)\>

## RELATED LINKS
