# Get-IAMReport

## SYNOPSIS
Generate and parse AWS IAM report

## SYNTAX

```
Get-IAMReport [[-ProfileName] <String>] [[-Credential] <AWSCredentials>] [[-Path] <String>]
 [<CommonParameters>]
```

## DESCRIPTION
This function will use the supplied AWS Credential profile to generate and
parse the IAM Credential Report.
It then returns the account information.

## EXAMPLES

### EXAMPLE 1
```
Get-IAMReport -ProfileName MyAccount
Generate IAM report for MyAccount
```

## PARAMETERS

### -ProfileName
Name property of an AWS credential profile

```yaml
Type: String
Parameter Sets: (All)
Aliases:

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

### -Path
File path to existing AWS Credential Report

```yaml
Type: String
Parameter Sets: (All)
Aliases: Data, CredentialReport, File, FilePath, Report, ReportPath

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String.
## OUTPUTS

### System.Object[].
## NOTES

## RELATED LINKS
