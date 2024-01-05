# Update-CFNStackAMI

## SYNOPSIS
Update CloudFormation stack with latest AMI ID

## SYNTAX

### __crd (Default)
```
Update-CFNStackAMI [-Path] <String> [-OSVersion] <String> [-Region] <String> -Credential <AWSCredentials>
 [-Force] [-WhatIf] [-Confirm] [<CommonParameters>]
```

### __pro
```
Update-CFNStackAMI [-Path] <String> [-OSVersion] <String> [-Region] <String> -ProfileName <String> [-Force]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Update CloudFormation stack Mappings \>\> RegionMap with latest AMI ID for
specified region

## EXAMPLES

### EXAMPLE 1
```
Update-CFNStackAMI -Path C:\cfnStack.template -OSVersion Server2019
Get the latest Windows Server 2019 AMI from AWS and update the RegionMap with the Image ID
```

## PARAMETERS

### -Path
Path to CloudFormation template file

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OSVersion
Windows OS version

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Region
AWS region

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
AWS Credential Object

```yaml
Type: AWSCredentials
Parameter Sets: __crd
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileName
AWS credential profile name

```yaml
Type: String
Parameter Sets: __pro
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Proceed with changes without prompting for confirmation

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None.
## OUTPUTS

### None.
## NOTES
Name:     Update-CFNStackAMI
Author:   Justin Johns
Version:  0.1.0 | Last Edit: 2022-07-11
- Initial version
Comments: \<Comment(s)\>
General notes

## RELATED LINKS
