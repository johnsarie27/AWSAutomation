---
external help file: AWSReporting-help.xml
Module Name: AWSReporting
online version:
schema: 2.0.0
---

# Export-SecurityGroup

## SYNOPSIS
Export Security Groups from a CloudFormation template

## SYNTAX

```
Export-SecurityGroup [-TemplateFile] <String> [<CommonParameters>]
```

## DESCRIPTION
Export Security Groups from a CloudFormation template to an Excel spreadsheet

## EXAMPLES

### Example 1
```powershell
PS C:\> Export-SecurityGroup -TF C:\template.template
```

Exports Security Groups from template.template

## PARAMETERS

### -TemplateFile
CloudFormation template file

```yaml
Type: String
Parameter Sets: (All)
Aliases: TF, Template, CF, File, Path, CloudFormation

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
