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
Edit-AWSProfile [-Create] [-Default] -Region <String> -ProfileName <String> [<CommonParameters>]
```

### _create
```
Edit-AWSProfile [-Create] -ProfileName <String> [<CommonParameters>]
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
Allows for managemnt of AWS Profile Credentials by prompting the user
for the necessary information to perform an initialization task.
Profiles can be created, updated, set as default, or removed.

## EXAMPLES

### EXAMPLE 1
```
Edit-AWSProfile -List
Display all existing profiles
```

### EXAMPLE 2
```
Edit-AWSProfile -Create -ProfileName MyProfile
Create new profile named MyProfile
```

### EXAMPLE 3
```
Edit-AWSProfile -Update -ProfileName Profile1
Update existing profile Profile1
```

## PARAMETERS

### -List
List profiles

```yaml
Type: SwitchParameter
Parameter Sets: _list
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Create
Create new profile

```yaml
Type: SwitchParameter
Parameter Sets: _create_default, _create
Aliases:

Required: True
Position: Named
Default value: False
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
Default value: False
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
Default value: False
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
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Region
Set AWS Region

```yaml
Type: String
Parameter Sets: _create_default, _update_default
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
Parameter Sets: _create_default, _create, _update_default, _update, _delete
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String.
## OUTPUTS

### System.String.
## NOTES
Using "-AsSecureString" prevents from copy and past when running the script

## RELATED LINKS

[https://docs.aws.amazon.com/powershell/latest/userguide/specifying-your-aws-credentials.html#pstools-cred-provider-chain](https://docs.aws.amazon.com/powershell/latest/userguide/specifying-your-aws-credentials.html#pstools-cred-provider-chain)

