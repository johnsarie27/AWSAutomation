---
external help file: AWSAutomation-help.xml
Module Name: AWSAutomation
online version:
schema: 2.0.0
---

# Disable-InactiveUserProfile

## SYNOPSIS
Disable unused IAM User Profile

## SYNTAX

### all (Default)
```
Disable-InactiveUserProfile -ProfileName <String> [-Age <Int32>] [-All] [-ReportOnly] [<CommonParameters>]
```

### user
```
Disable-InactiveUserProfile -ProfileName <String> [-Age <Int32>] -User <User[]> [-ReportOnly] [<CommonParameters>]
```

## DESCRIPTION
Disable any IAM User Profiles that has not been used in 90 or more days

## EXAMPLES

### Example 1
```powershell
PS C:\> Disable-InactiveUserProfile -ProfileName MyAWSAccount
```

Deactivate all profiles if not used in 90 days for MyAWSAccount

## PARAMETERS

### -Age
Age to disable accounts

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
- iam:GetLoginProfile
- iam:DeleteLoginProfile

## RELATED LINKS
