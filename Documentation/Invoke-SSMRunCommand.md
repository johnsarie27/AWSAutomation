# Invoke-SSMRunCommand

## SYNOPSIS
Send SNS run command

## SYNTAX

```
Invoke-SSMRunCommand [-Command] <ScriptBlock> [[-Comment] <String>] [[-ComputerName] <String[]>]
 [[-Tag] <Target>] [[-TimeoutSeconds] <Int32>] [[-TopicARN] <String>] [[-RoleName] <String>]
 [-ProfileName] <String> [-Region] <String> [<CommonParameters>]
```

## DESCRIPTION
Send SNS run command with some pre-established values

## EXAMPLES

### EXAMPLE 1
```
Invoke-SSMRunCommand -Command { Get-Service } -Comment 'Get services' -ComputerName MyComputer @commonParams
Runs the command "Get-Service" on system with name tag MyComputer
```

### EXAMPLE 2
```
Invoke-SSMRunCommand -Command { Get-Service } -Comment 'Get services' -Tag @{Key='Env';Values='Production'} @commonParams
Runs the command "Get-Service" on all systems with the 'Production' tag assigned
```

## PARAMETERS

### -Command
Command to execute in PowerShell

```yaml
Type: ScriptBlock
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Comment
SSM command comment

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ComputerName
Computer name to run command on

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Tag
Instance name tag

```yaml
Type: Target
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -TimeoutSeconds
Timeout in seconds

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: 3600
Accept pipeline input: False
Accept wildcard characters: False
```

### -TopicARN
SNS Topic ARN for notification

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RoleName
SNS service role name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileName
AWS Profile

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 8
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

Required: True
Position: 9
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None.
## OUTPUTS

### System.Object.
## NOTES
Name:     Invoke-SSMRunCommand
Author:   Justin Johns
Version:  0.1.2 | Last Edit: 2024-05-01
Comments: \<Comment(s)\>

## RELATED LINKS
