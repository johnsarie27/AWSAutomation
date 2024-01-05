# Export-CertificateReport

## SYNOPSIS
Export report for certificates

## SYNTAX

### __pro (Default)
```
Export-CertificateReport [[-Path] <String>] [-ProfileName] <String> [[-Region] <String>] [<CommonParameters>]
```

### __crd
```
Export-CertificateReport [[-Path] <String>] [-Credential] <AWSCredentials> [[-Region] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
Export report for certificates in Amazon Certificate Manager (similar to UI)

## EXAMPLES

### EXAMPLE 1
```
Export-CertificateReport -ProfileName myProfile -Region us-east-1 -Path C:\certReport.xlsx
Generate report of certificates in Amazon Certificate Manager to C:\certReport.xlsx
```

## PARAMETERS

### -Path
Path to export report

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: "$HOME\Desktop\CertificateReport_{0}.xlsx" -f (Get-Date -Format FileDateTime)
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
Position: 2
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
Position: 2
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
Position: 3
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
Name:     Export-CertificateReport
Author:   Justin Johns
Version:  0.1.0 | Last Edit: 2024-01-05
- 0.1.0 - Initial version
Comments: \<Comment(s)\>
General notes

## RELATED LINKS
