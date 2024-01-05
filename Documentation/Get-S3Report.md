# Get-S3Report

## SYNOPSIS
Get report information from S3

## SYNTAX

### __pro (Default)
```
Get-S3Report [-ProfileName] <String> [[-Region] <String>] [<CommonParameters>]
```

### __crd
```
Get-S3Report [-Credential] <AWSCredentials> [[-Region] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get report information on all S3 buckets in an account and region regarding
version, MFA deletion, and lifecycle policy rules for aborted incomplete
multi-part uploads

## EXAMPLES

### EXAMPLE 1
```
Get-S3Report -ProfileName myProfile -Region us-west-2
Return an array of objects containing information on the S3 bucket version and lifecycle policies
```

## PARAMETERS

### -ProfileName
Name property of an AWS credential profile

```yaml
Type: String
Parameter Sets: __pro
Aliases:

Required: True
Position: 1
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
Position: 1
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
Position: 2
Default value: Us-east-1
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
Name:     Get-S3Report
Author:   Justin Johns
Version:  0.1.0 | Last Edit: 2024-01-04
- 0.1.0 - Initial version
Comments: \<Comment(s)\>
General notes

## RELATED LINKS
