---
external help file: AWSReporting-help.xml
Module Name: AWSReporting
online version:
schema: 2.0.0
---

# Get-AvailableEBS

## SYNOPSIS
Get EBS volumes that are unattached to an EC2 instance

## SYNTAX

### all (Default)
```
Get-AvailableEBS [-Region <String>] [-AllProfiles] [<CommonParameters>]
```

### targeted
```
Get-AvailableEBS [-Region <String>] [-ProfileName <String[]>] [<CommonParameters>]
```

## DESCRIPTION
This function returns a list of custom objects with properties from AWS EBS volume objects
 where each EBS volume is available (unattached).

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-AvailableEBS | Group -Property Account | Select Name, Count
```

Get available EBS volumes, group them by Account, then show each Account name and number of volumes

## PARAMETERS

### -AllProfiles
All available AWS Credential Profiles

```yaml
Type: SwitchParameter
Parameter Sets: all
Aliases: All

Required: False
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

Required: False
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

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
