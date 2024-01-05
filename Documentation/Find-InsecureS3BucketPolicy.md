# Find-InsecureS3BucketPolicy

## SYNOPSIS
Find S3 bucket policies with insecure principle

## SYNTAX

```
Find-InsecureS3BucketPolicy [[-ProfileName] <String>] [[-Credential] <AWSCredentials>] [[-BucketName] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
This function scans through bucket policies for given bucket(s) to identify
policies that contain principles allowing unauthenticated access.

## EXAMPLES

### EXAMPLE 1
```
Find-InsecureS3BucketPolicy -ProfileName MyProfile
Search through all buckets in account represented by MyProfile for bucket
policies that allow non-authenticated principles.
```

## PARAMETERS

### -ProfileName
AWS Credential Profile name

```yaml
Type: String
Parameter Sets: (All)
Aliases: Profile, Name

Required: False
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
