---
external help file: AWSReporting-help.xml
Module Name: AWSReporting
online version:
schema: 2.0.0
---

# Edit-AWSProfile

## SYNOPSIS
Manage AWS Credential Profiles

## SYNTAX

### _list
```
Edit-AWSProfile [-List] [<CommonParameters>]
```

### _create_default
```
Edit-AWSProfile [-Create] [-Default] -Region <String> [-ProfileName <String>] [<CommonParameters>]
```

### _create
```
Edit-AWSProfile [-Create] [-ProfileName <String>] [<CommonParameters>]
```

### _update_default
```
Edit-AWSProfile [-Update] [-Default] -Region <String> -ProfileName <String> [<CommonParameters>]
```

### _update
```
Edit-AWSProfile [-Update] -ProfileName <String> [<CommonParameters>]
```

### _delete
```
Edit-AWSProfile [-Delete] -ProfileName <String> [<CommonParameters>]
```

## DESCRIPTION
Allows for managemnt of AWS Profile Credentials by prompting the user for the necessary information to perform a specific task. Profiles can be created, updated, set as default, or removed.

## EXAMPLES

### Example 1
```powershell
PS C:\> Edit-AWSProfile -List
```

Display all existing profiles

### Example 2
```powershell
PS C:\> Edit-AWSProfile -Create -ProfileName MyProfile
```

Create new profile named MyProfile

## PARAMETERS

### -Create
Create new profile

```yaml
Type: SwitchParameter
Parameter Sets: _create_default, _create
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Default
Set profile as default

```yaml
Type: SwitchParameter
Parameter Sets: _create_default, _update_default
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Delete
Remove existing profile

```yaml
Type: SwitchParameter
Parameter Sets: _delete
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -List
List profiles

```yaml
Type: SwitchParameter
Parameter Sets: _list
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileName
Profile name

```yaml
Type: String
Parameter Sets: _create_default, _create
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

```yaml
Type: String
Parameter Sets: _update_default, _update, _delete
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Region
Set AWS Region

```yaml
Type: String
Parameter Sets: _create_default, _update_default
Aliases:
Accepted values: us-east-1, us-east-2, us-west-1, us-west-2

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Update
Update existing profile

```yaml
Type: SwitchParameter
Parameter Sets: _update_default, _update
Aliases:

Required: True
Position: Named
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

### System.String
## NOTES

## RELATED LINKS
