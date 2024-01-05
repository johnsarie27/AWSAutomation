# ConvertFrom-CFLog

## SYNOPSIS
Convert from CloudFront distribution log

## SYNTAX

```
ConvertFrom-CFLog [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION
Convert data from CloudFront distribution log into object(s)

## EXAMPLES

### EXAMPLE 1
```
ConvertFrom-CFLog -Path C:\cloudfront.log
Converts content of log file "cloudfront.log" to objects
```

## PARAMETERS

### -Path
Path to log file

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String.
## OUTPUTS

### System.Object.
## NOTES
Name:     ConvertFrom-CFLog
Author:   Justin Johns
Version:  0.1.0 | Last Edit: 2023-10-30
- 0.1.0 - Initial version
Comments: \<Comment(s)\>
General notes

## RELATED LINKS
