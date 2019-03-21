---
external help file: AWSReporting-help.xml
Module Name: AWSReporting
online version:
schema: 2.0.0
---

# Disable-InactiveUserKey

## SYNOPSIS
Deactivate unused IAM User Access Key

## SYNTAX

### all (Default)
```
Disable-InactiveUserKey -ProfileName <String> [-Age <Int32>] [-All] [-Remove] [-ReportOnly] [<CommonParameters>]
```

### user
```
Disable-InactiveUserKey -ProfileName <String> [-Age <Int32>] [-Remove] -User <User[]> [-ReportOnly] [<CommonParameters>]
```

## DESCRIPTION
Deactivate IAM User Access Key that has not been used in 90 or more days

## EXAMPLES

### Example 1
```powershell
PS C:\> Disable-InactiveUserKey -ProfileName MyAWSAccount
```

Deactivate all access keys for all users that have not been used in 90 days for MyAWSAccount profile.

## PARAMETERS

### -Age
Age to disable keys

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -All
All users in account

```yaml
Type: SwitchParameter
Parameter Sets: all
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileName
AWS credential profile name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Remove
Delete key

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

### -User
User name

```yaml
Type: User[]
Parameter Sets: user
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ReportOnly
Report non-compliant keys only

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### Amazon.IdentityManagement.Model.User[]

## OUTPUTS

### System.Object
## NOTES
The identity running this function requires the following permissions:
- iam:ListUsers
- iam:ListAccessKeys
- iam:GetAccessKeyLastUsed
- iam:DeleteAccessKey
- iam:UpdateAccessKey

## RELATED LINKS
