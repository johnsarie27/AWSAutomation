# Find-PublicS3Objects

## SYNOPSIS
Find publicly accessible S3 objects

## SYNTAX

```
Find-PublicS3Objects [-ProfileName] <String> [[-Credential] <AWSCredentials>] [[-BucketName] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Search S3 bucket(s) and return a list of publicly accessible objects

## EXAMPLES

### EXAMPLE 1
```
Find-PublicS3Objects -ProfileName MyAccount
Search all objects in all S3 buckets for MyAccount and return a list of publicly accessible objects
```

## PARAMETERS

### -ProfileName
AWS Credential Profile name

```yaml
Type: String
Parameter Sets: (All)
Aliases: Profile, Name

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
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BucketName
S3 bucket name

```yaml
Type: String
Parameter Sets: (All)
Aliases: Bucket

Required: False
Position: 3
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String. Find-S3BucketPolicy accepts a string value for BucketName
## OUTPUTS

### System.Object.
## NOTES

## RELATED LINKS
