---
external help file: AWSReporting-help.xml
Module Name: AWSReporting
online version:
schema: 2.0.0
---

# Get-EC2

## SYNOPSIS
Get EC2 instances from multiple AWS accounts

## SYNTAX

```
Get-EC2 [-ConfigurationData] <String> [[-Region] <String>] [-All] [-AWSPowerShell] [<CommonParameters>]
```

## DESCRIPTION
This function returns a list of the EC2 instances in production or in all available AWS credential profiles.

## EXAMPLES

### Example 1
```powershell
PS C:\> $All = Get-EC2 -ConfigurationDate $C
```

Get all EC2 instances and store them in an array $All

## PARAMETERS

### -AWSPowerShell
Use AWSPowerShell module

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -All
All Profiles

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ConfigurationData
Configuration data file

```yaml
Type: String
Parameter Sets: (All)
Aliases: ConfigFile, DataFile, CofnigData, File, Path

Required: True
Position: 0
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
Accepted values: us-east-1, us-east-2, us-west-1, us-west-2

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
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
