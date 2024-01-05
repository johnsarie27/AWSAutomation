# New-HealthCheckAlarm

## SYNOPSIS
Create new CloudWatch Alarm for Route53 Health Check

## SYNTAX

### __crd (Default)
```
New-HealthCheckAlarm -Name <String> -HealthCheckId <String> -AlarmActionArn <String>
 -Credential <AWSCredentials> -Region <String> [<CommonParameters>]
```

### __pro
```
New-HealthCheckAlarm -Name <String> -HealthCheckId <String> -AlarmActionArn <String> -ProfileName <String>
 -Region <String> [<CommonParameters>]
```

## DESCRIPTION
Create new CloudWatch Alarm for Route53 Health Check using set values

## EXAMPLES

### EXAMPLE 1
```
New-HealthCheckAlarm
Explanation of what the example does
```

## PARAMETERS

### -Name
Alarm Name

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

### -HealthCheckId
Health Check ID

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

### -AlarmActionArn
AWS ARN of Alarm Action

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

### -ProfileName
Name property of an AWS credential profile

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

### -Region
AWS Region

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None.
## OUTPUTS

### None.
## NOTES
Name:     New-HealthCheckAlarm
Author:   Justin Johns
Version:  0.1.0 | Last Edit: 2022-05-26
- \<VersionNotes\> (or remove this line if no version notes)
Comments: \<Comment(s)\>
General notes

## RELATED LINKS
