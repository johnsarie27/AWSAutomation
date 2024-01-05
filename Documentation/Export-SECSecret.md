# Export-SECSecret

## SYNOPSIS
Export secret from Secrets Manager

## SYNTAX

### __crd (Default)
```
Export-SECSecret [-SecretId] <String> [-DestinationPath] <String> -Credential <AWSCredentials> -Region <String>
 [<CommonParameters>]
```

### __pro
```
Export-SECSecret [-SecretId] <String> [-DestinationPath] <String> -ProfileName <String> -Region <String>
 [<CommonParameters>]
```

## DESCRIPTION
Export secret from Secrets Manager as a secure string into a text file

## EXAMPLES

### EXAMPLE 1
```
Export-SECSecret -SecretId mySecret -DestinationPath C:\
Explanation of what the example does
```

## PARAMETERS

### -SecretId
ID of secret in Secrets Manager

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

### -DestinationPath
Path to export file

```yaml
Type: String
Parameter Sets: (All)
Aliases: Path

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
Position: Named
Default value: None
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

### System.String.
## NOTES
Name:      Export-SECSecret
Author:    Justin Johns
Version:   0.1.1 | Last Edit: 2022-04-06
- Updated action for existing file
Comments: \<Comment(s)\>
General notes

## RELATED LINKS
