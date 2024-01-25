# Get-CertificateReport

## SYNOPSIS
Get report data for certificates

## SYNTAX

### __pro (Default)
```
Get-CertificateReport [-ImportedOnly] [-ProfileName] <String> [[-Region] <String>] [<CommonParameters>]
```

### __crd
```
Get-CertificateReport [-ImportedOnly] [-Credential] <AWSCredentials> [[-Region] <String>] [<CommonParameters>]
```

## DESCRIPTION
Get report data for certificates in Amazon Certificate Manager (similar to UI)

## EXAMPLES

### EXAMPLE 1
```
Get-CertificateReport -ProfileName myProfile -Region us-east-1
Generate report of certificates in Amazon Certificate Manager to C:\certReport.xlsx
```

## PARAMETERS

### -ImportedOnly
Return IMPORTED certificates only

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: False
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
Position: 3
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
Position: 3
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
Position: 4
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
Name:     Get-CertificateReport
Author:   Justin Johns
Version:  0.1.1 | Last Edit: 2024-01-08
- 0.1.1 - (2024-01-05) Changed function from Export- to Get-CertificateReport
- 0.1.0 - (2024-01-05) Initial version
Comments: \<Comment(s)\>
General notes

## RELATED LINKS
