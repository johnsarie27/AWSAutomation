---
external help file: AWSAutomation-help.xml
Module Name: AWSAutomation
online version:
schema: 2.0.0
---

# Get-InstanceList

## SYNOPSIS
Get list of EC2 instances

## SYNTAX

```
Get-InstanceList [[-ProfileName] <String[]>] [[-Region] <String>] [<CommonParameters>]
```

## DESCRIPTION
This function queries AWS EC2 API for all instances in a given region for a given account. It requires an AWS Credential Profile and uses a custom class to store the data.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-InstanceList -Region us-east-1 -ProfileName MyAccount
```

Get a list of all EC2 instances in the AWS account represented by MyAccount in the us-east-1 region

## PARAMETERS

### -ProfileName
AWS Profile containing access key and secret

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Profile

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
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

### System.String[]

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
