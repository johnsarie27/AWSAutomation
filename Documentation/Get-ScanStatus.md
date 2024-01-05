# Get-ScanStatus

## SYNOPSIS
Get S3 Virus Scan Status

## SYNTAX

### _creds (Default)
```
Get-ScanStatus -BucketName <String> [-KeyPrefix <String>] -Credential <AWSCredentials> [<CommonParameters>]
```

### _profile
```
Get-ScanStatus -BucketName <String> [-KeyPrefix <String>] -ProfileName <String> [<CommonParameters>]
```

## DESCRIPTION
Get S3 Virus Scan Status

## EXAMPLES

### EXAMPLE 1
```
Get-ScanStatus -ProfileName myAcc -BucketName 'test-bucket-02340989' -KeyPrefix 'Docs'
Search all S3 objects in folder 'Docs' of bucket 'test-bucket-02340989' for tags with value "infected"
```

## PARAMETERS

### -BucketName
S3 Bucket Name

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

### -KeyPrefix
Key prefix to filter bucket resutls

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileName
AWS Credential Profile Name

```yaml
Type: String
Parameter Sets: _profile
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
Parameter Sets: _creds
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

### System.Object[].
## NOTES
General notes

## RELATED LINKS
