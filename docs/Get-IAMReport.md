---
external help file: AWSReporting-help.xml
Module Name: AWSReporting
online version:
schema: 2.0.0
---

# Get-IAMReport

## SYNOPSIS
Generate and parse AWS IAM report

## SYNTAX

```
Get-IAMReport [-ProfileName] <String> [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION
Generate and parse the IAM Credential Report and return the account information.

## EXAMPLES

### Example 1
```powershell
PS C:\> Get-IAMReport -ProfileName MyAccount
```

Generate IAM report for MyAccount

## PARAMETERS

### -Path
Existing AWS Credential Report

```yaml
Type: String
Parameter Sets: (All)
Aliases: Data, CredentialReport, File, FilePath, Report, ReportPath

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileName
AWS Credential profile

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String[]

## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
