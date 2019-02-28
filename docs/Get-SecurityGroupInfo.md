---
external help file: AWSReporting-help.xml
Module Name: AWSReporting
online version:
schema: 2.0.0
---

# Get-SecurityGroupInfo

## SYNOPSIS
Retrieve security group information from an AWS VPC

## SYNTAX

```
Get-SecurityGroupInfo [-ProfileName] <String> [[-Region] <String>] [-VpcId] <String> [<CommonParameters>]
```

## DESCRIPTION
This function retrieves all security groups from the provided VPC and outputs an object with a subset of the data, including the EC2 instances, in a format easy to use

## EXAMPLES

### Example 1
```powershell
PS C:\> $a = Get-SecurityGroupInfo -ProfileName $P -VpcId $V
```

Store all security groups from Profile $P and VPC $V in varibale $a

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
