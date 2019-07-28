---
external help file: AWSAutomation-help.xml
Module Name: AWSAutomation
online version:
schema: 2.0.0
---

# Find-InsecureS3BucketPolicy

## SYNOPSIS
Find S3 bucket policies with insecure principle

## SYNTAX

```
Find-InsecureS3BucketPolicy [-ProfileName] <String> [[-BucketName] <String>] [<CommonParameters>]
```

## DESCRIPTION
This function scans through bucket policies for given bucket(s) to identify policies that contain principles allowing unauthenticated access.

## EXAMPLES

### Example 1
```powershell
PS C:\> Find-InsecureS3BucketPolicy -ProfileName MyProfile
```

Search through all buckets in account represented by MyProfile for bucket policies that allow non-authenticated principles.

## PARAMETERS

### -BucketName
S3 bucket name

```yaml
Type: String
Parameter Sets: (All)
Aliases: Bucket

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ProfileName
AWS Credential Profile name

```yaml
Type: String
Parameter Sets: (All)
Aliases: Profile, Name

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
