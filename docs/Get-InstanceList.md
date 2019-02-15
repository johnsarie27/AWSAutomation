---
external help file: AWSReporting-help.xml
Module Name: AWSReporting
online version:
schema: 2.0.0
---

# Get-InstanceList

## SYNOPSIS
Get list of EC2 instances in given account

## SYNTAX

```
Get-InstanceList [[-Region] <String>] [[-ProfileName] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
This function queries AWS EC2 API for all instances in a given region for a given account.
 It requires an AWS Credential Profile and uses a custom class to store the data.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-InstanceList -Region $Region -ProfileName $ProfileName
```

Get all EC2 instances in given region for account represented by given credential profile

## PARAMETERS

### -ProfileName
AWS Profile containing access key and secret

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Profile

Required: False
Position: 1
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
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String
### System.String[]
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
