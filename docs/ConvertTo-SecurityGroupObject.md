---
external help file: AWSAutomation-help.xml
Module Name: AWSAutomation
online version:
schema: 2.0.0
---

# ConvertTo-SecurityGroupObject

## SYNOPSIS
Converts Security Groups to an object that can be used to populate a CloudFormation template.

## SYNTAX

```
ConvertTo-SecurityGroupObject [-ProfileName] <String> [[-Region] <String>] [[-VpcId] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
This function takes an existing set of Security Groups contained in a VPC and outputs an object that can esily be converted into JSON for a CloudFormation template.

## EXAMPLES

### Example 1
```powershell
PS C:\> $a = ConvertTo-SecurityGroupObject -ProfileName $P -Region us-east-1 -VpcId $v
PS C:\> $a | ConvertTo-Json -Depth 8
```

This will create the JSON that can be edited to fit into a CloudFormation template.

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

Required: False
Position: 2
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
