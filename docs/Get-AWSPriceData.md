---
external help file: AWSReporting-help.xml
Module Name: AWSReporting
online version:
schema: 2.0.0
---

# Export-AWSPriceData

## SYNOPSIS
Get price data for EC2 resources

## SYNTAX

```
Export-AWSPriceData [[-OfferCode] <String>] [[-Format] <String>] [<CommonParameters>]
```

## DESCRIPTION
This function retrieves the EC2 price data for AWS us-east-1 region and returns a CSV file with the relevant data.

## EXAMPLES

### Example 1
```powershell
PS C:\> GetPriceInfo -Region us-west-2
```

Get pricing info for EC2 resources in the us-west-2 region

## PARAMETERS

### -Format
Output format

```yaml
Type: String
Parameter Sets: (All)
Aliases: Output
Accepted values: .csv

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OfferCode
AWS offer code

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: 'AmazonEC2'

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

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
