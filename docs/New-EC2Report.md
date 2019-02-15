---
external help file: AWSReporting-help.xml
Module Name: AWSReporting
online version:
schema: 2.0.0
---

# New-EC2Report

## SYNOPSIS
Generate reports for instances offline and running without reservation

## SYNTAX

```
New-EC2Report [[-Region] <String>] [[-ProfileName] <String[]>] [-ConfigurationData] <String>
 [<CommonParameters>]
```

## DESCRIPTION
This script iterates through all instances in a give AWS Region and creates a list of specific attributes.
 It then finds the last stop time, user who stopped the instance, and calculates the number of days the
 system has been stopped (if possible) and creates a data sheet (CSV). The data sheet is then imported
 into Excel and formatted.  This can be done for a single or multiple accounts based on AWS Credentail Profiles.

## EXAMPLES

### Example 1
```powershell
PS C:\> New-EC2Report -Region us-west-1 -ProfileName MyAccountName
```

Generate new EC2 report for account represented by credential profile MyAccountName in us-west-1 region

## PARAMETERS

### -ConfigurationData
Configuration data file

```yaml
Type: String
Parameter Sets: (All)
Aliases: ConfigFile, DataFile, CofnigData, File, Path

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileName
AWS Credential Profie with key and secret

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Profile, PN

Required: False
Position: 1
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
Position: 0
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
