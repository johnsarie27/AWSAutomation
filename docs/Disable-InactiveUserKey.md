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

### _deactivate (Default)
```
Disable-InactiveUserKey -UserName <String> -ProfileName <String> [-Deactivate] [<CommonParameters>]
```

### _remove
```
Disable-InactiveUserKey -UserName <String> -ProfileName <String> [-Remove] [<CommonParameters>]
```

## DESCRIPTION
Deactivate any IAM User Access Key that has not been used in 90 or more days.

## EXAMPLES

### Example 1
```powershell
PS C:\> Disable-InactiveUserKey -UserName jsmith -ProfileName MyAWSAccount
```

Deactivate all access keys for jsmith that have not been used in 90 days for MyAWSAccount profile.

## PARAMETERS

### -Deactivate
Disable key

```yaml
Type: SwitchParameter
Parameter Sets: _deactivate
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
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Remove
Delete key

```yaml
Type: SwitchParameter
Parameter Sets: _remove
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserName
User name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
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
