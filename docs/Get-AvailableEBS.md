---
external help file: AWSAutomation-help.xml
Module Name: AWSAutomation
online version:
schema: 2.0.0
---

# Get-AvailableEBS

## SYNOPSIS
Get "unattached" Elastic Block Store volumes

## SYNTAX

### all (Default)
```
Get-AvailableEBS [-Region <String>] [-AllProfiles] [<CommonParameters>]
```

### targeted
```
Get-AvailableEBS -ProfileName <String[]> [-Region <String>] [<CommonParameters>]
```

## DESCRIPTION
This function returns a list of custom objects with properties from AWS EBS volume objects where each EBS volume is available (unattached).

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-AvailableEBS -AllProfiles | Group -Property Account | Select Name, Count
```

Get unattached EBS volumes, group them by Account, and display Name and Count

## PARAMETERS

### -AllProfiles
All available AWS Credential Profiles

```yaml
Type: SwitchParameter
Parameter Sets: all
Aliases: All

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileName
AWS Credential Profile name

```yaml
Type: String[]
Parameter Sets: targeted
Aliases: Profile, Name

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Region
Name of desired AWS Region.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: us-east-1, us-east-2, us-west-1, us-west-2

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
