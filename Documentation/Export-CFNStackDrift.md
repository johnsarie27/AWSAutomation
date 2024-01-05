# Export-CFNStackDrift

## SYNOPSIS
Explort CloudFormation drift results

## SYNTAX

```
Export-CFNStackDrift [[-Credential] <AWSCredentials>] [[-ProfileName] <String>] [[-Region] <String>]
 [-StackName] <String> [-SheetName] <String> [[-Path] <String>] [<CommonParameters>]
```

## DESCRIPTION
Explort CloudFormation drift results including difference line numbers.
The function will wait 5 seconds between initiation drift detection and
gathering results.

## EXAMPLES

### EXAMPLE 1
```
Export-CFNStackDrift -ProfileName myProfile -StackName Stack1 -SheetName Stack1 -Path "$HOME\Desktop\StackDrift.xlsx"
Exports an Excel Spreadsheet containing the objects IN_SYNC and DRIFTED in separate tabs
```

## PARAMETERS

### -Credential
AWS Credential Object

```yaml
Type: AWSCredentials
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProfileName
AWS Credential Profile name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
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
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StackName
CloudFormation Stack Name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SheetName
Excel Workbook Sheet name

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path
Output path for report

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
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
General notes

## RELATED LINKS
