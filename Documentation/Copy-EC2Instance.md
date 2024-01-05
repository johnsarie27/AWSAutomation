# Copy-EC2Instance

## SYNOPSIS
Copy EC2 Instance

## SYNTAX

### __pro (Default)
```
Copy-EC2Instance -EC2Instance <Instance> -Name <String> -Type <String> -AMIID <String> -ProfileName <String>
 -Region <String> [<CommonParameters>]
```

### __crd
```
Copy-EC2Instance -EC2Instance <Instance> -Name <String> -Type <String> -AMIID <String>
 -Credential <AWSCredentials> -Region <String> [<CommonParameters>]
```

## DESCRIPTION
Create copy of EC2 Instance based on existing instance.
This will copy
all relevant properties including specific tags, IAM profile, subnet,
and security groups

## EXAMPLES

### EXAMPLE 1
```
Copy-EC2Instance -EC2Instance $ec2 -Name MyNewEC2 -Type m6i.large -AMIID $aid
Makes a copy of EC2 Instance $ec2 with new name MyNewEC2 and type m61.large
```

## PARAMETERS

### -EC2Instance
EC2 Instance object to copy

```yaml
Type: Instance
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
Hostname of new EC2 Instance

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

### -Type
Instance type for new EC2 Instance

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

### -AMIID
AMI ID for new EC2 Instance

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
AWS Profile Name

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
AWS region

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

### System.Object.
## NOTES
Name:    Copy-EC2Instance
Author:  Justin Johns
Version: 0.1.4 | Last Edit: 2023-07-19
- 0.1.4 - Added support for AWS Credential Profile
- 0.1.3 - Code clean
- 0.1.2 - Update comments
- 0.1.0 - Initial version
Comments: \<Comment(s)\>
General notes

## RELATED LINKS
