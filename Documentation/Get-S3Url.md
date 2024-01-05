# Get-S3Url

## SYNOPSIS
Get S3 object URL

## SYNTAX

```
Get-S3Url [-BucketName] <String> [[-Region] <String>] [-Key] <String> [<CommonParameters>]
```

## DESCRIPTION
Get S3 object URL

## EXAMPLES

### EXAMPLE 1
```
Get-S3Url -BucketName myBucket -Key Files/Test/readme.txt
Returns the URL "https://myBucket.s3.us-east-1.amazonaws.com/Files/Test/readme.txt"
```

## PARAMETERS

### -BucketName
S3 Bucket name

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

### -Region
AWS Region

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

### -Key
S3 Object key

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

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None.
## OUTPUTS

### System.String.
## NOTES
Name:     Get-S3Url
Author:   Justin Johns
Version:  0.1.0 | Last Edit: 2023-11-02
- 0.1.0 - Initial version
Comments: \<Comment(s)\>
General notes

## RELATED LINKS
