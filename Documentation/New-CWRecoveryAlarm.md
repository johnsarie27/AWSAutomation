# New-CWRecoveryAlarm

## SYNOPSIS
Create new CloudWatch Alarm to Recover Instance

## SYNTAX

```
New-CWRecoveryAlarm [-InstanceId] <String[]> [[-ProfileName] <String>] [[-Credential] <AWSCredentials>]
 [[-Region] <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Create new CloudWatch Alarm to Recover Instance based on standard criteria

## EXAMPLES

### EXAMPLE 1
```
New-CWRecoveryAlarm -InstanceId 'i-00000000' -ProfileName 'MyProfie'
Adds a CloudWatch Alarm to the instance configured to recover after 2 failed status checks of 5 minutes each
```

## PARAMETERS

### -InstanceId
EC2 Instance Id

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Id, Instance

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ProfileName
Name property of an AWS credential profile

```yaml
Type: String
Parameter Sets: (All)
Aliases: Profile, Name

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
AWS Credential Object

```yaml
Type: AWSCredentials
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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

Required: False
Position: 4
Default value: None
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

### System.String.
## OUTPUTS

### System.String.
## NOTES
General notes

## RELATED LINKS
