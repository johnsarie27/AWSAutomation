---
external help file: AWSReporting-help.xml
Module Name: AWSReporting
online version:
schema: 2.0.0
---

# Get-ELB

## SYNOPSIS
Get Elastic Load Balancers

## SYNTAX

```
Get-ELB [[-ProfileName] <String[]>] [[-Region] <String>] [<CommonParameters>]
```

## DESCRIPTION
This function will return a list of AWS Elastic Load Balancers based on the Region and credentials (ProfileName) provided it. Not all properties are included and a few custom properties, namely IPAddress, has been added.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-ELB -ProfileName MyAccount
```

Get all Elastic Load Balancers in account represented by MyAccount profile

## PARAMETERS

### -ProfileName
AWS Credential Profile name

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Profile

Required: False
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

Required: False
Position: 1
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
