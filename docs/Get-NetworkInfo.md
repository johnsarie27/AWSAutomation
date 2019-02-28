---
external help file: AWSReporting-help.xml
Module Name: AWSReporting
online version:
schema: 2.0.0
---

# Get-NetworkInfo

## SYNOPSIS
Get AWS network infrastructure

## SYNTAX

```
Get-NetworkInfo [-ProfileName] <String> [[-Region] <String>] [-VpcId] <String> [<CommonParameters>]
```

## DESCRIPTION
This function iterates through the networking infrastructure (VPC's, Subnets, and Route Tables) and outputs a list of objects using the Route Tables as a connection point.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-NetworkInfo -ProfileName $P $Region 'us-east-1' -VpcId vpc-12345678
```

Get network infrastructure details for VPC vpc-12345678 in us-east-1 for store profile.

## PARAMETERS

### -ProfileName
AWS Profile containing key and secret

```yaml
Type: String
Parameter Sets: (All)
Aliases:

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
Accept pipeline input: False
Accept wildcard characters: False
```

### -VpcId
VPC ID

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByValue)
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
