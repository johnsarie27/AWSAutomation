# Get-AwsServiceReference

## SYNOPSIS
Gets the reference object for the provided AWS Service(s).

## SYNTAX

```
Get-AwsServiceReference [[-ServiceName] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
See https://docs.aws.amazon.com/service-authorization/latest/reference/service-reference.html

## EXAMPLES

### EXAMPLE 1
```
Get-AwsServiceReference
Returns list of all AWS Services and their reference URLs.
```

### EXAMPLE 2
```
Get-AwsServiceReference -ServiceName 'ssm'
Returns the reference information for the AWS Systems Manager (SSM) service.
```

### EXAMPLE 3
```
Get-AwsServiceReference -ServiceName 'ssm','s3'
Returns the reference information for the AWS Systems Manager (SSM) and Amazon Simple Storage Service (S3) services.
```

## PARAMETERS

### -ServiceName
AWS Service Name

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None.
## OUTPUTS

### System.Object
## NOTES
Name:     Get-AwsServiceReference
Author:   Phillip Glodowski
Version:  0.0.1 | Last Edit: 2025-08-28
- Version history is captured in repository commit history
Comments:

## RELATED LINKS
